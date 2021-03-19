package org.pmvp.nano

import org.pmvp.Proxy

data class ItemModel(
    override val key: String,
    override val updatedAt: Double,
    override val createdAt: Double,
    override val discardedAt: Double?,
    val name: String
) : Proxy<String>, Updatable<ItemModel>, Creatable, Discardable<ItemModel> {
    override fun copyWithUpdatedAt(updatedAt: Double): ItemModel =
        copy(updatedAt = updatedAt)

    override fun copyWithDiscardedAt(discardedAt: Double): ItemModel =
        copy(discardedAt = discardedAt)

}
