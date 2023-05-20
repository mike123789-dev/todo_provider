import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:todo_provider/main.dart';
import 'package:todo_provider/models/todo.dart';
import 'package:todo_provider/providers/todo_list_provider.dart';

void main() {
  group('Todo App Tests', () {
    testWidgets('Adding a Todo', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => TodoListProvider(),
          child: MaterialApp(
            home: TodoListScreen(),
          ),
        ),
      );

      // Enter text into the TextField
      await tester.enterText(find.byType(TextField), 'New Todo');

      // Tap the Add button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Verify that the todo is added to the list
      expect(find.text('New Todo'), findsOneWidget);
    });

    testWidgets('Toggling Todo Completion', (WidgetTester tester) async {
      final todo = Todo(
        title: 'Test Todo',
      );

      final provider = TodoListProvider();
      provider.addTodo(todo);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: MaterialApp(
            home: TodoListScreen(),
          ),
        ),
      );

      // Tap the checkbox to toggle completion
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // Verify that the todo's completion is toggled
      expect(provider.todos[0].completed, isTrue);
    });
  });
}
