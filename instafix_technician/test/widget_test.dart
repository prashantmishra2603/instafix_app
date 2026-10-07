import 'package:flutter_test/flutter_test.dart';
import 'package:instafix_technician/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const InstafixTechnicianApp());
    expect(find.byType(InstafixTechnicianApp), findsOneWidget);
  });
}
