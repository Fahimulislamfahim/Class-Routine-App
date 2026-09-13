import 'package:flutter_test/flutter_test.dart';
import 'package:swe_routine/main.dart';
import 'package:swe_routine/providers/routine_provider.dart';

void main() {
  testWidgets('ClassRoutineApp smoke test', (WidgetTester tester) async {
    final provider = RoutineProvider();
    await provider.loadSampleRoutine();

    await tester.pumpWidget(ClassRoutineApp(provider: provider));
    await tester.pumpAndSettle();

    expect(find.text('University Routine Extractor'), findsOneWidget);
    expect(find.text('Department of Software Engineering'), findsOneWidget);
    expect(find.text('Section: D'), findsOneWidget);
    expect(find.text('Batch: 42'), findsOneWidget);
  });
}
