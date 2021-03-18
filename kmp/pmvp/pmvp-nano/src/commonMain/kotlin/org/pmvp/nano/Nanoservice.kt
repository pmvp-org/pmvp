package org.pmvp.nano

import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.flow
import org.pmvp.Proxy

/**
 * Nanoservice is responsible for receiving requests from mobile devices in service of
 * synchronizing their data stores in an offline-first environment. Changes made by the mobile
 * device are received and interpreted. Results from each row in the request are reported back to
 * the client, along with any updates unknown to the client, such as changes made by other clients.
 *
 */
class Nanoservice<K, T>(
        private val queryable: Queryable<K, T>,
        private val responseFactory: JournalResponseFactory<K, T>,
        private val journalResultFactory: JournalResultFactory<K>,
        private val modelFactory: ModelFactory<K, T>,
        private val pageLimit: Int = 1000
) : JournalService<K, T> where T : Proxy<K>, T : Updatable<T>, T : Creatable, T : Discardable<T> {

    /**
     * Primary method for processing requests.
     *
     * Fetches records matching the affected keys from the request. Then attempts to reconcile
     * each entry in the request against the last known state of the record. Finally compiles a
     * response object with the status of each entry, along with the next batch of records modified
     * since the reference date specified in the request.
     *
     * @param request received from client, with record modification entries and a reference date.
     * @return a cold [Flow] with a single [JournalResponse] payload.
     */
    override fun process(request: JournalRequest<K, T>): Flow<JournalResponse<K, T>> = flow {
        // fetch records matching the affected keys
        val existingMap = queryable.get(request.entries.map { it.key }).first()

        // process submitted entries and update status
        val status: List<JournalResult<K>> = request.entries.map { entry ->
            when (entry.op) {
                JournalType.CREATE.name -> createRecord(entry, existingMap)
                JournalType.UPDATE.name -> updateRecord(entry, existingMap)
                JournalType.DELETE.name -> deleteRecord(entry, existingMap)
                else -> journalResultFactory.build(entry.key, JournalResultCode.UNKNOWN)
            }
        }

        // fetch a batch of records modified since the request reference date
        val responseRecords = queryable.records(request.since, limit = pageLimit).first()

        // compile response
        emit(
                responseFactory.build(
                        status = status,
                        records = responseRecords
                )
        )
    }

    /**
     * Delegate method responsible for attempting creation of a record.
     *
     * Checks the "existing records" map for a record matching the given key. If one exists, ignore
     * the request. Otherwise, insert the new record.
     */
    private suspend fun createRecord(
            entry: JournalEntry<K, T>,
            existingMap: Map<K, T>
    ): JournalResult<K> {
        val found = existingMap[entry.key]
        if (found == null) {
            // not found; insert the new record
            queryable.create(modelFactory.build(entry)).first()
            return journalResultFactory.build(key = entry.key, code = JournalResultCode.SUCCESS)
        } else {
            // found existing; ignore entry
            return journalResultFactory.build(key = entry.key, code = JournalResultCode.ALREADY_CREATED)
        }
    }

    /**
     * Delegate method responsible for attempting upsert of a record.
     *
     * Checks the "existing records" map for a record matching the given key. If a match is not
     * found, the entry is ignored. If one exists, compare its `updatedAt` property against the
     * entry `effectiveAt` property. Entries with values newer than the last known modification are
     * updated; otherwise, the entry is ignored.
     */
    private suspend fun updateRecord(
            entry: JournalEntry<K, T>,
            existingMap: Map<K, T>
    ): JournalResult<K> {
        val found = existingMap[entry.key]
        if (found == null) {
            // not found; ignore entry
            return journalResultFactory.build(key = entry.key, code = JournalResultCode.NOT_FOUND)
        } else {
            if (found.updatedAt < entry.effectiveAt) {
                // entry is more recent; update record
                val updatedModel = modelFactory.from(found, entry).copyWithUpdatedAt(entry.effectiveAt)
                queryable.update(updatedModel).first()
                return journalResultFactory.build(key = entry.key, code = JournalResultCode.SUCCESS)
            } else {
                // entry is older; ignore it
                return journalResultFactory.build(key = entry.key, code = JournalResultCode.OUTDATED_UPDATE)
            }
        }
    }

    /**
     * Delegate method responsible for attempting to discard a record.
     *
     * Checks the "existing records" map for a record matching the given key. If a match is not
     * found, the entry is ignored. If a record is found with a non-null `discardedAt` value, the
     * entry is ignored. Otherwise, the record is marked as discarded.
     */
    private suspend fun deleteRecord(
            entry: JournalEntry<K, T>,
            existingMap: Map<K, T>
    ): JournalResult<K> {
        val found: T? = existingMap[entry.key]
        if (found == null) {
            // not found; ignore entry
            return journalResultFactory.build(key = entry.key, code = JournalResultCode.NOT_FOUND)
        } else if (found.discardedAt != null) {
            // found but already discarded; ignore entry
            return journalResultFactory.build(key = entry.key, code = JournalResultCode.ALREADY_DELETED)
        } else {
            // mark as discarded and update
            val discardedModel = modelFactory.from(found, entry).copyWithDiscardedAt(entry.effectiveAt)
            queryable.update(discardedModel).first()
            return journalResultFactory.build(key = entry.key, code = JournalResultCode.SUCCESS)
        }
    }

    private enum class JournalType {
        CREATE,
        UPDATE,
        DELETE
    }

}
