package org.pmvp.nano

import kotlinx.coroutines.InternalCoroutinesApi
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.runBlocking
import org.junit.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

@InternalCoroutinesApi
class ItemNanoserviceTest {

    val pattern = "yyyy-M-dd'T'HH:mm:ss.SSSZ"

    private fun buildItem(key: String, name: String, createdAt: Double, updatedAt: Double): ItemModel =
        ItemModel(
            key = key,
            name = name,
            createdAt = createdAt,
            updatedAt = updatedAt,
            discardedAt = null
        )

    private class ItemQueryable(
        private val map: MutableMap<String, ItemModel>
    ): Queryable<String, ItemModel> {
        override fun get(keys: List<String>): Flow<Map<String, ItemModel>> = flow {
            val result: Map<String, ItemModel> = hashMapOf<String, ItemModel>().apply {
                keys.forEach { key -> map[key]?.let { put(key, it) } }
            }
            emit(result)
        }

        override fun create(model: ItemModel): Flow<ItemModel> = flow {
            map.put(model.key, model)
            emit(model)
        }

        override fun update(model: ItemModel): Flow<ItemModel> = flow {
            map.put(model.key, model)
            emit(model)
        }

        override fun records(since: Double, limit: Int): Flow<List<ItemModel>> = flow {
            val limitedEntries = map.values
                .filter { it.updatedAt > since }
                .sortedBy { it.updatedAt }
                .take(limit)
            emit(limitedEntries)
        }

        fun all(): Flow<List<ItemModel>> = flow {
            emit(map.values.toList())
        }
    }

    private fun buildNanoservice(itemQueryable: Queryable<String, ItemModel>) =
            ItemNanoservice(
                    queryable = itemQueryable,
                    responseFactory = ItemResponseFactory(),
                    journalResultFactory = ItemJournalResultFactory(),
                    modelFactory = ItemModelFactory()
            )

    @Test
    fun testEmptyRequest() = runBlocking {
        val service = buildNanoservice(ItemQueryable(hashMapOf()))
        val now = 1508675309.0
        val request = ItemRequest(
            since = now,
            entries = emptyList()
        )
        val response = service.process(request).first()
        assertEquals(0, response.status.count(), "wrong status count")
        assertEquals(0, response.records.count(), "wrong records count")
    }

    @Test
    fun testCreateNonConflictingRequest() = runBlocking {
        val d1 = 1508675309.0
        val existing = buildItem("item1", "Item1", d1, d1)

        val itemQueryable = ItemQueryable(hashMapOf(existing.key to existing))
        val service = buildNanoservice(itemQueryable)

        val d2 = 1508675310.0
        val request = ItemRequest(
            since = d1,
            entries = listOf(
                ItemJournalEntry(
                    op = "CREATE",
                    key = "field2",
                    effectiveAt = d2,
                    payload = existing.copy(name = "Item2")
                )
            )
        )
        val response = service.process(request).first()
        assertEquals(1, response.status.count(), "wrong status count")
        assertEquals(1, response.records.count(), "wrong records count")
        val stored = itemQueryable.all().first().filter { it.updatedAt > request.since }
        assertEquals(1, stored.count(), "wrong stored count")
        val stored1 = stored.first()
        assertEquals("Item2", stored1.name, "wrong name")
    }

    @Test
    fun testUpdateNonConflictingRequest() = runBlocking {
        val d1 = 1508675309.0
        val existing = buildItem("item1", "Item1", d1, d1)

        val itemQueryable = ItemQueryable(hashMapOf(existing.key to existing))
        val service = buildNanoservice(itemQueryable)

        val d2 = 1508675310.0
        val request = ItemRequest(
            since = existing.updatedAt,
            entries = listOf(
                ItemJournalEntry(
                    op = "UPDATE",
                    key = existing.key,
                    effectiveAt = d2,
                    payload = existing.copy(name = "Item2")
                )
            )
        )
        val response = service.process(request).first()
        assertEquals(1, response.status.count(), "wrong status count")
        assertEquals(1, response.records.count(), "wrong record count")
        val first = response.records.first()
        assertEquals("Item2", first.name, "wrong name")
        assertEquals(d2, first.updatedAt, "wrong updatedAt")
    }

    @Test
    fun testUpdateConflictingOutdatedRequest() = runBlocking {
        val d1 = 1508675309.0
        val existing = buildItem("field1", "Item1", d1, d1.plus(10000))

        val itemQueryable = ItemQueryable(hashMapOf(existing.key to existing))
        val service = buildNanoservice(itemQueryable)

        val d2 = 1508675309.0
        val request = ItemRequest(
            since = d1,
            entries = listOf(
                ItemJournalEntry(
                    op = "UPDATE",
                    key = existing.key,
                    effectiveAt = d2,
                    payload = existing.copy(name = "Item2")
                )
            )
        )
        val response = service.process(request).first()
        assertEquals(1, response.status.count(), "wrong status count")
        val status = response.status.first()
        assertEquals(JournalResultCode.OUTDATED_UPDATE, status.code, "should error")
        assertEquals(1, response.records.count(), "wrong record count")
        val first = response.records.first()
        assertEquals("Item1", first.name, "should ignore the request")
        assertEquals(existing.updatedAt, first.updatedAt, "wrong updatedAt")
    }

}
