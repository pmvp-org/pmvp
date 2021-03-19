package org.pmvp.nano

import kotlinx.coroutines.InternalCoroutinesApi

data class ItemJournalEntry(
    override var op: String,
    override var key: String,
    override var effectiveAt: Double,
    override var payload: ItemModel
): JournalEntry<String, ItemModel>

class ItemResponseFactory: JournalResponseFactory<String, ItemModel> {
    override fun build(
        status: List<JournalResult<String>>,
        records: List<ItemModel>
    ): JournalResponse<String, ItemModel> = JournalResponse(
        status = status,
        records = records
    )
}

class ItemJournalResultFactory: JournalResultFactory<String> {
    override fun build(key: String, code: JournalResultCode, message: String?): JournalResult<String> {
        return ItemJournalResult(
            key = key,
            code = code,
            message = message
        )
    }
}

data class ItemJournalResult(
    override val key: String,
    override val code: JournalResultCode,
    override val message: String?
) : JournalResult<String>

class ItemRequest(
    override val since: Double,
    override val entries: List<JournalEntry<String, ItemModel>>
) : JournalRequest<String, ItemModel>

class ItemModelFactory: ModelFactory<String, ItemModel> {
    override fun build(entry: JournalEntry<String, ItemModel>): ItemModel =
        ItemModel(
            key = entry.key,
            name = entry.payload.name,
            updatedAt = entry.effectiveAt,
            createdAt = entry.effectiveAt,
            discardedAt = null
        )

    override fun from(model: ItemModel, entry: JournalEntry<String, ItemModel>): ItemModel {
        var result: ItemModel = model
        entry.payload.name.let { result = result.copy(name = it) }
        return result
    }
}

@InternalCoroutinesApi
typealias ItemNanoservice = Nanoservice<String, ItemModel>
