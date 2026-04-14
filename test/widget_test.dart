import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:focus_tap/app/app.dart';
import 'package:focus_tap/repositories/local_storage_repository.dart';

void main() {
  testWidgets('FocusTap shell renders main navigation', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repository = await LocalStorageRepository.create();

    await tester.pumpWidget(FocusTapApp(storageRepository: repository));
    await tester.pumpAndSettle();

    expect(find.text('FocusTap'), findsOneWidget);
    expect(find.text('TODO'), findsOneWidget);
    expect(find.text('Timer'), findsOneWidget);
    expect(find.text('Break'), findsOneWidget);
    expect(find.text('Stats'), findsOneWidget);
  });
}
