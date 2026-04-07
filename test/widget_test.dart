import 'package:flutter_test/flutter_test.dart';
import 'package:roadygo_rider/app/app.dart';

void main() {
  testWidgets('app opens rider dashboard from welcome screen', (tester) async {
    await tester.pumpWidget(const RoadyGoRiderApp());

    expect(find.text('Vunigo'), findsOneWidget);
    expect(find.text('Enter rider app'), findsOneWidget);

    await tester.tap(find.text('Enter rider app'));
    await tester.pumpAndSettle();

    expect(find.text('Where are you heading?'), findsOneWidget);
    expect(find.text('Saved places'), findsOneWidget);
  });
}
