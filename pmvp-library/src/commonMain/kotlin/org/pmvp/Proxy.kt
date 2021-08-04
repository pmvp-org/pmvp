package org.pmvp

import kotlinx.coroutines.flow.Flow

/**
 * Defines an individually addressable object, based on a primary key.
 */
interface Proxy<K> {
    val key: K
}

/**
 * Defines the read-only methods for accessing domain objects based on their primary keys.
 */
interface Immutable<K, T: Proxy<K>> {
    fun model(key: K): Flow<T?>
    fun models(keys: List<K>): Flow<List<T>>
}

/**
 * Defines the methods for updating or deleting objects based on their primary keys.
 */
interface Mutable<K, T: Proxy<K>> {
    fun upsert(model: T): Flow<T>
    fun delete(model: T): Flow<T>
}
