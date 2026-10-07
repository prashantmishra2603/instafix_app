import 'package:flutter_test/flutter_test.dart';
import 'package:instafix_customer/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const InstafixCustomerApp());
    expect(find.byType(InstafixCustomerApp), findsOneWidget);
  });
}
