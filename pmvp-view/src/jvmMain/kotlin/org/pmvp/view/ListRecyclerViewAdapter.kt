package org.pmvp.view

import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import androidx.viewbinding.ViewBinding
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach

interface ViewHolderDelegate<T: ListItem, B: ViewBinding> {
    fun build(parent: ViewGroup, viewType: Int): ListRecyclerViewAdapter.ListItemViewHolder<B>
    fun bind(binding: B, model: T)
}

/**
 * Binding adapter for connecting any [Flow<List<T>>] to a [RecyclerView].
 *
 * @param scope coroutine scope used for consuming the [itemSource].
 * @param itemSource external flow used to populate elements in the list.
 * @param viewHolderSource delegate for injecting domain-specific implementation of the item view itself
 * @param itemClickBinder closure for reacting to click events on items.
 */
class ListRecyclerViewAdapter<T: ListItem, B: ViewBinding>(
    scope: CoroutineScope,
    itemSource: Flow<List<T>>,
    private val viewHolderSource: ViewHolderDelegate<T, B>,
    private val itemClickBinder: (T) -> Unit
): RecyclerView.Adapter<ListRecyclerViewAdapter.ListItemViewHolder<B>>() {

    private var values: List<T> = emptyList()

    init {
        // initialize the values from the item source
        itemSource
            .onEach {
                values = it
                notifyDataSetChanged()
            }
            .launchIn(scope)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ListItemViewHolder<B> =
        viewHolderSource.build(parent, viewType)

    override fun onBindViewHolder(holder: ListItemViewHolder<B>, position: Int) {
        val item: T = values[position]
        holder.itemView.setOnClickListener {
            itemClickBinder(item)
        }
        viewHolderSource.bind(holder.itemBinding, item)
    }

    override fun getItemCount(): Int =
        values.count()

    class ListItemViewHolder<B: ViewBinding>(
        val itemBinding: B,
    ) : RecyclerView.ViewHolder(
        itemBinding.root
    )
}
