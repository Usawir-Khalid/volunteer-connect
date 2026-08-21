import 'package:flutter_test/flutter_test.dart';

import 'package:volunteer_connect/app/app.dart';

void main() {
  testWidgets('Volunteer Connect app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const VolunteerConnectApp());

    expect(find.text('Volunteer Connect'), findsOneWidget);
    expect(find.text('Make a difference.'), findsOneWidget);
  });
}