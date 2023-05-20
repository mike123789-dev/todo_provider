import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/todo.dart';
import 'providers/todo_list_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load todos before running the app
  final provider = TodoListProvider();
  await provider.loadTodos();

  runApp(
    ChangeNotifierProvider(
      create: (_) => provider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(useMaterial3: true),
      home: TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatelessWidget {
  final TextEditingController _textEditingController = TextEditingController();

  TodoListScreen({super.key});

  void _addTodo(BuildContext context) {
    final provider = Provider.of<TodoListProvider>(context, listen: false);
    final todoTitle = _textEditingController.text.trim();

    if (todoTitle.isNotEmpty) {
      final todo = Todo(
        title: todoTitle,
      );
      provider.addTodo(todo);
      _textEditingController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textEditingController,
                      decoration: const InputDecoration(
                        labelText: 'New Todo',
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _addTodo(context),
                    child: const Text('Add'),
                  ),
                ],
              ),
            ),
            const Divider(),
            const TodoList(),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: TodoCount(),
                    ),
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          final provider = context
                              .read<TodoListProvider>(); // Read the provider
                          provider.completeAllTodos();
                        },
                        child: const Text('Complete All'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          context.read<TodoListProvider>().removeAllTodos();
                        },
                        child: const Text('Remove All'),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class TodoList extends StatelessWidget {
  const TodoList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context
        .watch<TodoListProvider>(); // Listen to changes on TodoListProvider

    return Expanded(
      child: ListView.builder(
        itemCount: provider.todos.length,
        itemBuilder: (context, index) {
          final todo = provider.todos[index];
          return ListTile(
            title: Text(todo.title),
            trailing: Checkbox(
              value: todo.completed,
              onChanged: (_) {
                provider.toggleTodoCompletion(index);
              },
            ),
          );
        },
      ),
    );
  }
}

class TodoCount extends StatelessWidget {
  const TodoCount({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final totalTodosCount =
        context.select<TodoListProvider, int>((value) => value.totalTodos);
    final totalCompletedTodosCount = context
        .select<TodoListProvider, int>((value) => value.totalCompletedTodos);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Text('Total Todos: $totalTodosCount'),
          Text('Total Completed: $totalCompletedTodosCount'),
        ],
      ),
    );
  }
}
