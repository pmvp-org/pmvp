import com.squareup.sqldelight.Query
import io.mockk.MockKAnnotations
import io.mockk.every
import io.mockk.impl.annotations.MockK
import io.mockk.mockk
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.test.runBlockingTest
import org.pmvp.Proxy
import org.pmvp.sqldelight.ForeignKeyQueryable
import org.pmvp.sqldelight.QueryToFlowInvokable
import org.pmvp.sqldelight.SqlDelightForeignKeyStorage
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals

@ExperimentalCoroutinesApi
class SqlDelightForeignKeyStorageTest {

    @MockK
    private lateinit var queryable: ForeignKeyQueryable<String, String, TestProxy, TestProxy>

    init {
        MockKAnnotations.init(this)
    }

    private lateinit var storage: SqlDelightForeignKeyStorage<String, String, TestProxy, TestProxy>

    private var queryableGetCount = 0
    private var queryableUpdateCount = 0

    @Suppress("UNCHECKED_CAST")
    @BeforeTest
    fun setUp() {

        every { queryable.get(any(), any()) } answers {
            queryableGetCount++
            val keys = it.invocation.args[1] as List<TestProxy>
            val query = mockk<Query<TestProxy>>()
            every { query.executeAsList() } returns keys
            query
        }

        every { queryable.update(any(), any()) } answers {
            queryableUpdateCount++
            Unit
        }

        every { queryable.fromLocal(any()) } answers {
            TestProxy(it.invocation.args[0] as String)
        }

        storage = SqlDelightForeignKeyStorage(
            queryable = queryable,
            queryToFlow = object : QueryToFlowInvokable {
                override fun <T : Any> invoke(query: Query<T>): Flow<Query<T>> {
                    return flowOf(query)
                }
            })
    }

    @Test
    fun `test queryable gets called few times `() = verifyUpdateObjectsChunked(
        itemsToInsert = 2988,
        expectedChunks = 3
    )

    @Test
    fun `test queryable gets called 1 time only`() = verifyUpdateObjectsChunked(
        itemsToInsert = 999,
        expectedChunks = 1
    )

    @Test
    fun `test queryable gets called 0 time only`() = verifyUpdateObjectsChunked(
        itemsToInsert = 0,
        expectedChunks = 0
    )

    private fun verifyUpdateObjectsChunked(itemsToInsert: Int, expectedChunks: Int) = runBlockingTest {
        // setup:
        val proxies = (0 until itemsToInsert).map { TestProxy("$it") }
        // when:
        storage.updateObjects("test", proxies).first()
        // then:
        assertEquals(itemsToInsert, queryableUpdateCount, "Expected $itemsToInsert of updated items")
        assertEquals(
            expectedChunks,
            queryableGetCount,
            "Queryable get should be executed in chunks of ${SqlDelightForeignKeyStorage.pageSize} items a time"
        )
    }
}

internal data class TestProxy(override val key: String) : Proxy<String>

