
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../cubit/todo_cubit.dart';
import '../model/todo_model.dart';


class TodoScreen extends StatefulWidget {
const TodoScreen({super.key});

@override
State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
final titleController = TextEditingController();
final descriptionController = TextEditingController();

@override
void dispose() {
titleController.dispose();
descriptionController.dispose();
super.dispose();
}

void showMessage(String message) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text(message)),
);
}

Future<void> addTodo() async {
if (titleController.text.trim().isEmpty) {
showMessage('Please enter a title');
return;
}

await context.read<TodoCubit>().addTodo(
titleController.text,
descriptionController.text,
);

if (!mounted) return;

if (context.read<TodoCubit>().state is TodoSuccess) {
titleController.clear();
descriptionController.clear();
showMessage('Note added successfully');
}
}

Future<void> editTodo(TodoModel todo) async {
final editTitleController =
TextEditingController(text: todo.title);
final editDescriptionController =
TextEditingController(text: todo.description);

await showDialog(
context: context,
builder: (dialogContext) {
return AlertDialog(
title: const Text('Edit Todo'),
content: SingleChildScrollView(
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
TextField(
controller: editTitleController,
decoration: const InputDecoration(
labelText: 'Title',
),
),
TextField(
controller: editDescriptionController,
decoration: const InputDecoration(
labelText: 'Description',
),
),
],
),
),
actions: [
TextButton(
onPressed: () {
Navigator.pop(dialogContext);
},
child: const Text('Cancel'),
),
ElevatedButton(
onPressed: () async {
if (editTitleController.text.trim().isEmpty) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Title cannot be empty'),
),
);
return;
}

await context.read<TodoCubit>().updateTodo(
todo.id,
editTitleController.text,
editDescriptionController.text,
);

if (!mounted) return;

if (context.read<TodoCubit>().state
is TodoSuccess) {
Navigator.pop(dialogContext);
showMessage('Note updated successfully');
} else if (context.read<TodoCubit>().state
is TodoError) {
showMessage(
(context.read<TodoCubit>().state as TodoError)
    .message,
);
}
},
child: const Text('Save'),
),
],
);
},
);

editTitleController.dispose();
editDescriptionController.dispose();
}

Future<void> confirmDelete(TodoModel todo) async {
final confirm = await showDialog<bool>(
context: context,
builder: (dialogContext) {
return AlertDialog(
title: const Text('Delete Todo'),
content: Text('Delete "${todo.title}"?'),
actions: [
TextButton(
onPressed: () {
Navigator.pop(dialogContext, false);
},
child: const Text('Cancel'),
),
ElevatedButton(
onPressed: () {
Navigator.pop(dialogContext, true);
},
child: const Text('Delete'),
),
],
);
},
);

if (confirm == true) {
await context.read<TodoCubit>().deleteTodo(todo.id);

if (!mounted) return;

final state = context.read<TodoCubit>().state;

if (state is TodoSuccess) {
showMessage('Todo deleted successfully');
} else if (state is TodoError) {
showMessage(state.message);
}
}
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text('My Notes'),
centerTitle: true,
),
body: BlocListener<TodoCubit, TodoState>(
listener: (context, state) {
if (state is TodoError) {
showMessage(state.message);
}
},
child: Padding(
padding: const EdgeInsets.all(16),
child: Column(
children: [
TextField(
controller: titleController,
decoration: const InputDecoration(
labelText: 'Title',
border: OutlineInputBorder(),
),
),
const SizedBox(height: 10),
TextField(
controller: descriptionController,
decoration: const InputDecoration(
labelText: 'Description',
border: OutlineInputBorder(),
),
),
const SizedBox(height: 10),
BlocBuilder<TodoCubit, TodoState>(
builder: (context, state) {
if (state is TodoLoading) {
return const CircularProgressIndicator();
}

return SizedBox(
width: double.infinity,
child: ElevatedButton(
onPressed: addTodo,
child: const Text('Add Note'),
),
);
},
),
const SizedBox(height: 20),
const Align(
alignment: Alignment.centerLeft,
child: Text(
'My Notes',
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),
),
const SizedBox(height: 10),
Expanded(
child: StreamBuilder<QuerySnapshot>(
stream: FirebaseFirestore.instance
    .collection('todo')
    .snapshots(),
builder: (context, snapshot) {
if (snapshot.hasError) {
return const Center(
child: Text('Something went wrong'),
);
}

if (snapshot.connectionState ==
ConnectionState.waiting) {
return const Center(
child: CircularProgressIndicator(),
);
}

final documents = snapshot.data!.docs;

if (documents.isEmpty) {
return const Center(
child: Text('No notes yet'),
);
}

return ListView.builder(
itemCount: documents.length,
itemBuilder: (context, index) {
final document = documents[index];

final todo = TodoModel.fromMap(
document.id,
document.data() as Map<String, dynamic>,
);

return Card(
child: ListTile(

title: Text(
todo.title,
style: TextStyle(
decoration: todo.isDone
? TextDecoration.lineThrough
    : TextDecoration.none,
),
),
subtitle: Text(todo.description),
trailing: Row(
mainAxisSize: MainAxisSize.min,
children: [
IconButton(
icon: const Icon(Icons.edit),
onPressed: () => editTodo(todo),
),
IconButton(
icon: const Icon(
Icons.delete,
color: Colors.red,
),
onPressed: () => confirmDelete(todo),
),
],
),
),
);
},
);
},
),
),
],
),
),
),
);
}
}
