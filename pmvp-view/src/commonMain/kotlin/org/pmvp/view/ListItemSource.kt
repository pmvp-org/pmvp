package org.pmvp.view

import kotlinx.coroutines.flow.Flow

interface ListItemSource<T: ListItem> {
    val itemSource: Flow<List<T>>
}
