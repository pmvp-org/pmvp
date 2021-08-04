package org.pmvp.view

import kotlinx.coroutines.flow.Flow

interface ListSectionSource<T: ListItem> {
    val sectionSource: Flow<List<ListSection<T>>>
}
