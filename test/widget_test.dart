import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_giants/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: DailyGiantsApp()),
    );
    await tester.pumpAndSettle();
    expect(find.text('DAILY GIANTS'), findsOneWidget);
  });
}
