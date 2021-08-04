package org.pmvp

import kotlinx.coroutines.flow.Flow

/**
 * Primary storage interface for defining the upsert mechanism for a given domain object.
 */
interface Storage<K, T : Proxy<K>> {

    fun objects(): Flow<List<T>>

    fun objectFor(key: K): Flow<T?>

    fun objectsFor(keys: List<K>): Flow<List<T>>

    fun updateObject(proxy: T): Flow<T>

    fun updateObjects(proxies: List<T>): Flow<List<T>>

    fun destroyObject(proxy: T): Flow<T>

    fun destroyObjects(objects: List<T>): Flow<List<T>>
}