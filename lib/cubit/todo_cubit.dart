
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../model/todo_model.dart';

part 'todo_state.dart';

class TodoCubit extends Cubit<TodoState> {
TodoCubit() : super(TodoInitial());

var firestore = FirebaseFirestore.instance;
late var doc = firestore.collection('todo');

Future<void> addTodo(
String title,
String description,
) async {
if (title.trim().isEmpty) {
emit(TodoError('Title cannot be empty'));
return;
}

emit(TodoLoading());

try {
final todo = TodoModel(
id: '',
title: title.trim(),
description: description.trim(),
);

await doc.add(todo.toMap());

emit(TodoSuccess());
} catch (e) {
emit(TodoError(e.toString()));
}
}

Future<void> updateTodo(
String id,
String title,
String description,
) async {
if (title.trim().isEmpty) {
emit(TodoError('Title cannot be empty'));
return;
}

emit(TodoLoading());

try {
await doc.doc(id).update({
'title': title.trim(),
'description': description.trim(),
});

emit(TodoSuccess());
} catch (e) {
emit(TodoError(e.toString()));
}
}



Future<void> deleteTodo(String id) async {
emit(TodoLoading());

try {
await doc.doc(id).delete();

emit(TodoSuccess());
} catch (e) {
emit(TodoError(e.toString()));
}
}
}
