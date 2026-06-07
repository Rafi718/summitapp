import 'package:flutter_test/flutter_test.dart';
import 'package:summitapp/app.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const SummitApp());
    await tester.pump();

    expect(find.text('Summit'), findsOneWidget);
  });
}
