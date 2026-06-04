package com.remind.app.core.designsystem

import com.google.common.truth.Truth.assertThat
import org.junit.Test

class ReMindColorTest {
    @Test
    fun brandPaletteMatchesApprovedIdentity() {
        assertThat(ReMindPalette.InkHex).isEqualTo("#10171C")
        assertThat(ReMindPalette.SkyHex).isEqualTo("#97CFF3")
        assertThat(ReMindPalette.MintHex).isEqualTo("#A7E8D1")
        assertThat(ReMindPalette.CloudHex).isEqualTo("#F7F7F7")
    }

    @Test
    fun criticalAlarmPaletteUsesInkAndMintForHighContrastState() {
        assertThat(ReMindPalette.CriticalBackgroundHex).isEqualTo(ReMindPalette.InkHex)
        assertThat(ReMindPalette.CriticalAccentHex).isEqualTo(ReMindPalette.MintHex)
    }
}
