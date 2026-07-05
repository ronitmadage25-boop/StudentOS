// Basic StudentOS widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:studentos/main.dart';
import 'package:studentos/core/core.dart';

void main() {
  testWidgets('StudentOS App Smoke Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StudentOSApp());

    // Verify that the title dashboard greeting is shown.
    expect(find.text(AppStrings.greeting), findsOneWidget);
  });
}
