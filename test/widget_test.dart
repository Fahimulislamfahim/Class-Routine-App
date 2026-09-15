import 'package:flutter_test/flutter_test.dart';
import 'package:swe_routine/main.dart';
import 'package:swe_routine/providers/routine_provider.dart';

void main() {
  testWidgets('ClassRoutineApp smoke test', (WidgetTester tester) async {
    final provider = RoutineProvider();
    await provider.loadSampleRoutine();

    await tester.pumpWidget(ClassRoutineApp(provider: provider));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Interactive HUD'), findsOneWidget);
    expect(find.text('AI Vision Active'), findsOneWidget);
    expect(find.text('Routine'), findsOneWidget);
    expect(find.text('Matrix'), findsOneWidget);
    expect(find.text('Export'), findsOneWidget);
  });
}
