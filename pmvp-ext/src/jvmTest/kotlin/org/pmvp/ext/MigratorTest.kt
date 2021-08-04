package org.pmvp.ext

import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.firstOrNull
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach
import kotlinx.coroutines.test.runBlockingTest
import org.junit.Test
import org.pmvp.InMemoryStorage
import org.pmvp.Proxy
import kotlin.test.assertEquals
import kotlin.test.assertNotNull

@ExperimentalCoroutinesApi
class MigratorTest {

    private data class SourceModel(override val key: String): Proxy<String>

    private data class DestinationModel(override val key: String): Proxy<String>

    @Test
    fun testOneBatch() = runBlockingTest {
        val k1 = "key1"
        val sourceStorage = InMemoryStorage(mutableMapOf(k1 to SourceModel(k1)))
        val destStorage = InMemoryStorage<String, DestinationModel>()
        val migrator = Migrator(
            source = sourceStorage,
            destination = destStorage,
            transform = { DestinationModel(it.key) }
        )
        var results = emptyList<MigratorStatus>()
        migrator.performMigration()
            .onEach { results = results + listOf(it) }
            .launchIn(this)
        advanceUntilIdle()

        val item = destStorage.objectFor(k1).firstOrNull()
        assertNotNull(item)
        assertEquals(k1, item.key)
        val processing = results.filterIsInstance<MigratorStatus.Processing>()
        assertEquals(1, processing.count())
        assertEquals(1, processing.first().count)
        val completed = results.filterIsInstance<MigratorStatus.Completed>()
        assertEquals(1, completed.count())
        assertEquals(0, completed.first().failedCount)
        assertEquals(1, completed.first().successCount)
        assertEquals(1, completed.first().batchCount)
    }

    @Test
    fun testTwoBatches() = runBlockingTest {
        val keys = listOf("key1", "key2", "key3")
        val sourceStorage = InMemoryStorage(keys.map { it to SourceModel(it) }.toMap().toMutableMap())
        val destStorage = InMemoryStorage<String, DestinationModel>()
        val migrator = Migrator(
            source = sourceStorage,
            destination = destStorage,
            transform = { DestinationModel(it.key) },
            batchSize = 2
        )
        var results = emptyList<MigratorStatus>()
        migrator.performMigration()
            .onEach { results = results + listOf(it) }
            .launchIn(this)
        advanceUntilIdle()

        val items = destStorage.objects().firstOrNull()
        assertNotNull(items)
        keys.forEach { key ->
            assertEquals(key, items.filter { it.key == key }.first().key)
        }
        val processing = results.filterIsInstance<MigratorStatus.Processing>()
        assertEquals(1, processing.count())
        assertEquals(3, processing.first().count)
        val completed = results.filterIsInstance<MigratorStatus.Completed>()
        assertEquals(1, completed.count())
        assertEquals(0, completed.first().failedCount)
        assertEquals(3, completed.first().successCount)
        assertEquals(2, completed.first().batchCount)
    }
}