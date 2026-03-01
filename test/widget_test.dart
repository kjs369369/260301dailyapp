import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:daily_app/app.dart';

void main() {
  testWidgets('App smoke test - renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: DailyApp(),
      ),
    );

    // Verify that bottom navigation renders
    expect(find.text('홈'), findsOneWidget);
    expect(find.text('캘린더'), findsOneWidget);
    expect(find.text('통계'), findsOneWidget);
    expect(find.text('설정'), findsOneWidget);
  });
}
