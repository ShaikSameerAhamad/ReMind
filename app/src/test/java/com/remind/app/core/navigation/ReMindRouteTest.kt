package com.remind.app.core.navigation

import com.google.common.truth.Truth.assertThat
import org.junit.Test

class ReMindRouteTest {
    @Test
    fun taskDetailRouteRequiresGroupAndTaskIds() {
        val route = ReMindRoute.TaskDetail.createRoute(groupId = "group-1", taskId = "task-7")

        assertThat(route).isEqualTo("groups/group-1/tasks/task-7")
    }

    @Test
    fun alarmReceivedRouteRequiresGroupAndAlarmIds() {
        val route = ReMindRoute.AlarmReceived.createRoute(groupId = "family", alarmId = "alarm-2")

        assertThat(route).isEqualTo("groups/family/alarms/alarm-2/received")
    }
}
