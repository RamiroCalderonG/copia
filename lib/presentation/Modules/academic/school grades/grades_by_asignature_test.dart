import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxschool/core/utils/loader_indicator.dart';
import 'package:oxschool/presentation/Modules/academic/school%20grades/grades_by_asignature.dart';
import 'package:oxschool/presentation/components/custom_icon_button.dart';
import 'package:trina_grid/trina_grid.dart';

void main() {
  testWidgets('GradesByAsignature widget test', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GradesByAsignature(),
        ),
      ),
    );

    // Verify if the loading indicator is shown initially
    expect(find.byType(CustomLoadingIndicator), findsOneWidget);

    // Simulate fetching data
    await tester.pump();

    // Verify if the loading indicator is hidden after data is fetched
    expect(find.byType(CustomLoadingIndicator), findsNothing);

    // Verify if the TrinaGrid is displayed
    expect(find.byType(TrinaGrid), findsOneWidget);

    // Verify if the RefreshButton is displayed
    expect(find.byType(RefreshButton), findsOneWidget);

    // Verify if the ElevatedButton with save icon is displayed
    expect(find.widgetWithIcon(ElevatedButton, Icons.save), findsOneWidget);
  });
}
