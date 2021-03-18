package org.pmvp.nano

import org.pmvp.Proxy

data class JournalResponse<K, T: Proxy<K>>(
        val status: List<JournalResult<K>>,
        val records: List<T>
)

enum class JournalResultCode(val rawValue: Int) {
    SUCCESS(0),
    ALREADY_CREATED(1),
    NOT_FOUND(2),
    OUTDATED_UPDATE(3),
    ALREADY_DELETED(4),
    UNKNOWN(5)
}
