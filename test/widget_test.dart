import 'package:flutter_test/flutter_test.dart';
import 'package:airline_management_system/main.dart';

void main() {
  testWidgets('Airline Management System loads', (WidgetTester tester) async {
    await tester.pumpWidget(const AirlineManagementApp());

    expect(find.text('Customer Management'), findsOneWidget);
  });
}