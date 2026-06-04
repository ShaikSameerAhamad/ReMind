package com.remind.app.core.navigation

sealed class ReMindRoute(val pattern: String) {
    data object Auth : ReMindRoute("auth")
    data object Home : ReMindRoute("home")
    data object Save : ReMindRoute("save")
    data object Queue : ReMindRoute("queues/{queueId}") {
        fun createRoute(queueId: String): String = "queues/${queueId.requireRouteSegment("queueId")}"
    }

    data object Groups : ReMindRoute("groups")
    data object GroupDetail : ReMindRoute("groups/{groupId}") {
        fun createRoute(groupId: String): String = "groups/${groupId.requireRouteSegment("groupId")}"
    }

    data object TaskDetail : ReMindRoute("groups/{groupId}/tasks/{taskId}") {
        fun createRoute(groupId: String, taskId: String): String =
            "groups/${groupId.requireRouteSegment("groupId")}/tasks/${taskId.requireRouteSegment("taskId")}"
    }

    data object AlarmReceived : ReMindRoute("groups/{groupId}/alarms/{alarmId}/received") {
        fun createRoute(groupId: String, alarmId: String): String =
            "groups/${groupId.requireRouteSegment("groupId")}/alarms/${alarmId.requireRouteSegment("alarmId")}/received"
    }

    data object Settings : ReMindRoute("settings")
}

private fun String.requireRouteSegment(name: String): String {
    require(isNotBlank()) { "$name is required." }
    require(!contains("/")) { "$name cannot contain '/'." }
    return this
}
