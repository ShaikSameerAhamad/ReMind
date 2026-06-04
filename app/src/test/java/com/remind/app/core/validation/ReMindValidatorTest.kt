package com.remind.app.core.validation

import com.google.common.truth.Truth.assertThat
import org.junit.Test

class ReMindValidatorTest {
    @Test
    fun urlValidationAcceptsHttpsUrlsOnly() {
        assertThat(ReMindValidators.url("https://example.com/article")).isEqualTo(ValidationResult.Valid)
        assertThat(ReMindValidators.url("http://example.com")).isEqualTo(ValidationResult.Invalid("Use a secure https link."))
        assertThat(ReMindValidators.url("not a url")).isEqualTo(ValidationResult.Invalid("Enter a valid link."))
    }

    @Test
    fun taskTitleValidationRejectsBlankAndOverlongTitles() {
        assertThat(ReMindValidators.taskTitle("Buy groceries")).isEqualTo(ValidationResult.Valid)
        assertThat(ReMindValidators.taskTitle("   ")).isEqualTo(ValidationResult.Invalid("Task title is required."))
        assertThat(ReMindValidators.taskTitle("x".repeat(121))).isEqualTo(ValidationResult.Invalid("Task title must be 120 characters or less."))
    }

    @Test
    fun groupNameValidationRejectsBlankAndOverlongNames() {
        assertThat(ReMindValidators.groupName("Family Chores")).isEqualTo(ValidationResult.Valid)
        assertThat(ReMindValidators.groupName("")).isEqualTo(ValidationResult.Invalid("Group name is required."))
        assertThat(ReMindValidators.groupName("x".repeat(81))).isEqualTo(ValidationResult.Invalid("Group name must be 80 characters or less."))
    }
}
