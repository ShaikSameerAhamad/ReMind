package com.remind.app.domain.model

import com.google.common.truth.Truth.assertThat
import org.junit.Test

class PermissionModelTest {
    @Test
    fun groupAdminCanManageMembersAndDeleteOthersTasks() {
        val membership = GroupMembership(
            userId = "admin",
            displayName = "Admin",
            role = GroupRole.Admin,
            joinedAtEpochMillis = 1L,
            avatarUrl = null,
        )

        assertThat(membership.canManageMembers).isTrue()
        assertThat(membership.canDeleteTask(createdBy = "someone-else")).isTrue()
    }

    @Test
    fun groupMemberCannotManageMembersOrDeleteOthersTasks() {
        val membership = GroupMembership(
            userId = "member",
            displayName = "Member",
            role = GroupRole.Member,
            joinedAtEpochMillis = 1L,
            avatarUrl = null,
        )

        assertThat(membership.canManageMembers).isFalse()
        assertThat(membership.canDeleteTask(createdBy = "someone-else")).isFalse()
        assertThat(membership.canDeleteTask(createdBy = "member")).isTrue()
    }

    @Test
    fun guestCannotUseCloudCollaboration() {
        assertThat(UserAccess.Guest.canCreateCloudGroup).isFalse()
        assertThat(UserAccess.SignedIn(plan = SubscriptionPlan.Free).canCreateCloudGroup).isTrue()
    }
}
