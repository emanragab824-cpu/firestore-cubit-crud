part of 'todo_cubit.dart';

@immutable
sealed class TodoState {}

final class TodoInitial extends TodoState {}


class TodoLoading extends TodoState {}

class TodoSuccess extends TodoState {}

class TodoError extends TodoState {
  final String message;

  TodoError(this.message);
}