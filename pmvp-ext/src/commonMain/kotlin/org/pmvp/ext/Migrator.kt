package org.pmvp.ext

import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.flow
import org.pmvp.Proxy
import org.pmvp.Storage

/**
 * Constrained generic component designed for migrating data from one storage to another using a transform.
 * @param source
 * @param destination
 * @param transform closure used to convert source objects to destination type.
 * @param batchSize maximum size of batches used to insert objects in destination.
 */
class Migrator<K, T1 : Proxy<K>, T2 : Proxy<K>>(
    private val source: Storage<K, T1>,
    private val destination: Storage<K, T2>,
    private val transform: (T1) -> T2?,
    private val batchSize: Int = 500,
    private val abortOnFail: Boolean = false
) {
    fun performMigration(): Flow<MigratorStatus> = flow {
        emit(MigratorStatus.Started)
        // fetch all objects from source storage
        var allSourceObjects = source.objects().first()

        var failedTransformCount = 0
        var successCount = 0
        var batchCount = 0
        emit(MigratorStatus.Processing(allSourceObjects.count()))
        while (allSourceObjects.isNotEmpty()) {
            // fetch the next batch
            val sourceBatch = allSourceObjects.take(batchSize)
            val selectedElementCount = sourceBatch.count()
            // transform the elements
            val destinationBatch = sourceBatch.map { transform(it) }.filterNotNull()
            val countDelta = destinationBatch.count() - sourceBatch.count()
            if (countDelta > 0) {
                if (abortOnFail) {
                    // at least one element in the source batch failed to transform
                    emit(MigratorStatus.Failed)
                    return@flow
                }
                failedTransformCount += countDelta
            }
            // upsert the batch
            destination.updateObjects(destinationBatch).first()
            successCount += destinationBatch.count()
            // move cursor to next batch
            if (selectedElementCount < batchSize) {
                allSourceObjects = emptyList()
            } else {
                allSourceObjects = allSourceObjects.drop(batchSize)
            }
            batchCount += 1
        }
        emit(
            MigratorStatus.Completed(
                failedCount = failedTransformCount,
                successCount = successCount,
                batchCount = batchCount
            )
        )
    }
}

sealed class MigratorStatus {
    object Started : MigratorStatus()
    data class Processing(val count: Int) : MigratorStatus()
    data class Completed(
        val failedCount: Int,
        val successCount: Int,
        val batchCount: Int
    ) : MigratorStatus()

    object Failed : MigratorStatus()
}
