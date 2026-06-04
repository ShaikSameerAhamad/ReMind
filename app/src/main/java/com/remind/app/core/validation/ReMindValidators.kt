package com.remind.app.core.validation

import java.net.URI

object ReMindValidators {
    fun url(value: String): ValidationResult {
        val trimmed = value.trim()
        val uri = runCatching { URI(trimmed) }.getOrNull()
            ?: return ValidationResult.Invalid("Enter a valid link.")
        if (uri.scheme == null || uri.host == null) {
            return ValidationResult.Invalid("Enter a valid link.")
        }
        if (uri.scheme.lowercase() != "https") {
            return ValidationResult.Invalid("Use a secure https link.")
        }
        return ValidationResult.Valid
    }

    fun taskTitle(value: String): ValidationResult = boundedRequiredText(
        value = value,
        emptyMessage = "Task title is required.",
        maxLength = 120,
        tooLongMessage = "Task title must be 120 characters or less.",
    )

    fun groupName(value: String): ValidationResult = boundedRequiredText(
        value = value,
        emptyMessage = "Group name is required.",
        maxLength = 80,
        tooLongMessage = "Group name must be 80 characters or less.",
    )

    private fun boundedRequiredText(
        value: String,
        emptyMessage: String,
        maxLength: Int,
        tooLongMessage: String,
    ): ValidationResult {
        val trimmed = value.trim()
        return when {
            trimmed.isEmpty() -> ValidationResult.Invalid(emptyMessage)
            trimmed.length > maxLength -> ValidationResult.Invalid(tooLongMessage)
            else -> ValidationResult.Valid
        }
    }
}
