package org.pmvp.nano

import kotlinx.coroutines.flow.Flow
import org.pmvp.Proxy

interface Updatable<T> {
    val updatedAt: Double
    fun copyWithUpdatedAt(updatedAt: Double): T
}

interface Creatable {
    val createdAt: Double
}

interface Discardable<T> {
    val discardedAt: Double?
    fun copyWithDiscardedAt(discardedAt: Double): T
}

interface JournalService<K, T: Proxy<K>> {
    fun process(request: JournalRequest<K, T>): Flow<JournalResponse<K, T>>
}

interface JournalResultFactory<K> {
    fun build(key: K, code: JournalResultCode, message: String? = null): JournalResult<K>
}

interface JournalResponseFactory<K, T: Proxy<K>> {
    fun build(status: List<JournalResult<K>>, records: List<T>): JournalResponse<K, T>
}

interface ModelFactory<K, T> where T: Proxy<K>, T: Updatable<T>, T: Creatable {
    fun build(entry: JournalEntry<K, T>): T
    fun from(model: T, entry: JournalEntry<K, T>): T
}
