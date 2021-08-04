package org.pmvp.view

import kotlinx.coroutines.flow.Flow

interface ViewModelState

/**
 * A contract between ViewModel and a view for producing a [ViewModelState]'s.
 */
interface ViewModelStateProducer<T : ViewModelState> {
    val state: Flow<T>
}

interface ViewModelIntent

interface ViewModelIntentConsumer<N : ViewModelIntent> {
    fun onIntent(intent: N)
}

interface ViewModel<T : ViewModelState, N : ViewModelIntent> :
    ViewModelStateProducer<T>,
    ViewModelIntentConsumer<N>

/**
 * A common interface to be used in [ViewEventsProducer].
 * An example of event can be a toast message or a dialog. This event should be consumed only once and
 * it should not be persisted across subscriptions
 */
interface ViewModelEvent

/**
 * A contract between ViewModel and a view for producing a [ViewModelEvent]'s.
 */
interface ViewModelEventsProducer<T : ViewModelEvent> {
    val viewEvents: Flow<T>
}

