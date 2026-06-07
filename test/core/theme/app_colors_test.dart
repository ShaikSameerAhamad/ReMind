import 'package:flutter_test/flutter_test.dart';
import 'package:remind/core/theme/app_colors.dart';

void main() {
  test('brand palette matches approved reMind identity', () {
    expect(ReMindColors.ink.toARGB32(), 0xFF10171C);
    expect(ReMindColors.sky.toARGB32(), 0xFF97CFF3);
    expect(ReMindColors.mint.toARGB32(), 0xFFA7E8D1);
    expect(ReMindColors.cloud.toARGB32(), 0xFFF7F7F7);
  });
}
