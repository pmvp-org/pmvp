package org.pmvp

import kotlinx.coroutines.flow.Flow

/**
 * Responsible for orchestrating the local/remote sync process for a single domain object.
 */
interface SyncOrchestrator<K, T : Proxy<K>> {
    fun register(localStorage: Storage<K, T>, remoteStorage: Storage<K, T>)
    fun performSync(): Flow<Float>
}

/**
 * Responsible for orchestrating the local/remote sync process for a single domain object with
 * a foreign key constraint.
 */
interface ForeignKeySyncOrchestrator<FK, K, T : Proxy<K>> {
    fun register(localStorage: ForeignKeyStorage<FK, K, T>, remoteStorage: ForeignKeyStorage<FK, K, T>)
    fun performSync(foreignKey: FK): Flow<Float>
}
