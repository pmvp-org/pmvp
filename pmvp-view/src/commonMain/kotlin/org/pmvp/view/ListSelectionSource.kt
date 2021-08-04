package org.pmvp.view

import kotlinx.coroutines.flow.Flow

interface ListSelectionSource<T: ListItem> {
    val selectionSource: Flow<T?>
}
