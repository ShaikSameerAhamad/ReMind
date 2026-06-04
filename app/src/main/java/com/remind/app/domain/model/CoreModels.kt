package com.remind.app.domain.model

enum class ItemCategory {
    Article,
    Video,
    Product,
    Social,
    Recipe,
    Learning,
    Note,
}

enum class SyncStatus {
    Synced,
    Pending,
    Failed,
}

enum class GroupRole {
    Admin,
    Member,
}

enum class SubscriptionPlan {
    Free,
    Pro,
    Family,
}

sealed interface UserAccess {
    val canCreateCloudGroup: Boolean

    data object Guest : UserAccess {
        override val canCreateCloudGroup: Boolean = false
    }

    data class SignedIn(val plan: SubscriptionPlan) : UserAccess {
        override val canCreateCloudGroup: Boolean = true
    }
}

data class GroupMembership(
    val userId: String,
    val displayName: String,
    val role: GroupRole,
    val joinedAtEpochMillis: Long,
    val avatarUrl: String?,
) {
    val canManageMembers: Boolean = role == GroupRole.Admin

    fun canDeleteTask(createdBy: String): Boolean = role == GroupRole.Admin || createdBy == userId
}

data class SavedItem(
    val id: String,
    val ownerId: String,
    val title: String,
    val url: String,
    val category: ItemCategory,
    val sourceDomain: String?,
    val thumbnailUrl: String?,
    val readTimeMinutes: Int?,
    val savedAtEpochMillis: Long,
    val updatedAtEpochMillis: Long,
    val syncStatus: SyncStatus,
    val isCompleted: Boolean,
    val isArchived: Boolean,
    val readingProgress: Float,
)
