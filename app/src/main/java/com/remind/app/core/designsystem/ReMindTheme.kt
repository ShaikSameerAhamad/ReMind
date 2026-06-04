package com.remind.app.core.designsystem

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.ColorScheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalContext

private val LightColors = lightColorScheme(
    primary = ReMindPalette.Sky,
    onPrimary = ReMindPalette.Ink,
    secondary = ReMindPalette.Mint,
    onSecondary = ReMindPalette.Ink,
    background = ReMindPalette.Cloud,
    onBackground = ReMindPalette.Ink,
    surface = ReMindPalette.White,
    onSurface = ReMindPalette.Ink,
    error = ReMindPalette.Error,
    onError = ReMindPalette.White,
    outline = ReMindPalette.Border,
)

private val DarkColors = darkColorScheme(
    primary = ReMindPalette.Sky,
    onPrimary = ReMindPalette.Ink,
    secondary = ReMindPalette.Mint,
    onSecondary = ReMindPalette.Ink,
    background = ReMindPalette.Ink,
    onBackground = ReMindPalette.Cloud,
    surface = ReMindPalette.DarkSurface,
    onSurface = ReMindPalette.Cloud,
    error = ReMindPalette.Error,
    onError = ReMindPalette.White,
    outline = ReMindPalette.SecondaryText,
)

@Composable
fun ReMindTheme(
    useDarkTheme: Boolean = isSystemInDarkTheme(),
    useDynamicColor: Boolean = true,
    content: @Composable () -> Unit,
) {
    val context = LocalContext.current
    val dynamicScheme = when {
        useDynamicColor && useDarkTheme -> dynamicDarkColorScheme(context).withBrandActions()
        useDynamicColor -> dynamicLightColorScheme(context).withBrandActions()
        else -> null
    }

    MaterialTheme(
        colorScheme = dynamicScheme ?: if (useDarkTheme) DarkColors else LightColors,
        typography = ReMindTypography,
        content = content,
    )
}

private fun ColorScheme.withBrandActions(): ColorScheme = copy(
    primary = ReMindPalette.Sky,
    onPrimary = ReMindPalette.Ink,
    secondary = ReMindPalette.Mint,
    onSecondary = ReMindPalette.Ink,
)
