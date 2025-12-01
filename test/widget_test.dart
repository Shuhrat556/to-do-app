// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:todo_app/injection/injection_container.dart';
import 'package:todo_app/main.dart';

void main() {
  testWidgets('renders header and action button', (WidgetTester tester) async {
    WidgetsFlutterBinding.ensureInitialized();
    await init(directoryPath: Directory.systemTemp.path);
    await tester.pumpWidget(const ToDoProApp());
    await tester.pumpAndSettle();

    expect(find.text('ToDo Pro'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
