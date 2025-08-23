import 'package:flutter_test/flutter_test.dart';
import 'package:for_u_partners/app/app.locator.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('PickerCoursesViewModel Tests -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());
  });
}
