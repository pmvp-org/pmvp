package org.pmvp.nano

interface JournalEntry<K, T> {
    var op: String
    var key: K
    var effectiveAt: Double
    var payload: T
}

interface JournalRequest<K, T> {
    val since: Double
    val entries: List<JournalEntry<K, T>>
}

interface JournalResult<K> {
    val key: K
    val code: JournalResultCode
    val message: String?
}
