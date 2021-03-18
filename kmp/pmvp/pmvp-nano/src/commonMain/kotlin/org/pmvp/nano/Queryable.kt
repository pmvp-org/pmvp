package org.pmvp.nano

import kotlinx.coroutines.flow.Flow
import org.pmvp.Proxy

/**
 * Interface responsible for abstracting the persistent storage concerns using a standard method
 * signature for fetching by key or by batch, inserting, and updating.
 */
interface Queryable<K, T>
        where T: Proxy<K>,
              T: Updatable<T>,
              T: Creatable,
              T: Discardable<T>
{
    /**
     * Fetch records by primary key as a set
     *
     * @return a cold [Flow] with payload of a map of matching records
     */
    fun get(keys: List<K>): Flow<Map<K, T>>

    /**
     * Insert a new record
     *
     * @return a cold [Flow] of the inserted record
     */
    fun create(model: T): Flow<T>

    /**
     * Update an existing record; also used for discarding records by marking them with non-null
     * value for `discardedAt`.
     *
     * @return a cold [Flow] of the updated record
     */
    fun update(model: T): Flow<T>

    /**
     * Fetch records where `updatedAt` is greater than the `since` argument.
     *
     * @return a cold [Flow] of the ordered list of any matching records
     */
    fun records(since: Double, limit: Int): Flow<List<T>>
}
