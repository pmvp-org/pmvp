package org.pmvp

import kotlinx.coroutines.channels.ConflatedBroadcastChannel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.asFlow
import kotlinx.coroutines.flow.flow

/**
 * A dynamic in-memory wrapper around the [SingularStorage<T>] interface.
 */
open class InMemorySingularStorage<T>: SingularStorage<T> {

    private val channel = ConflatedBroadcastChannel<T?>(null)

    override fun get(): Flow<T?> =
        channel.asFlow()

    override fun update(model: T?): Flow<T?> = flow {
        channel.send(model)
        emit(model)
    }

}
