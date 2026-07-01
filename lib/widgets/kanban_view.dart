import 'package:emoapp/model/kanban.dart';
import 'package:emoapp/model/todo.dart';
import 'package:emoapp/view_model/topic_detail_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A full-screen kanban board view with columns for each state.
/// Allows drag-and-drop style interaction via dialogs and CRUD operations on states.
class KanbanView extends StatelessWidget {
  const KanbanView({required this.kanbanId, Key? key}) : super(key: key);

  final String kanbanId;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TopicDetailViewModel>();
    final kanban = viewModel.kanbans.firstWhere(
      (k) => k.id == kanbanId,
      orElse: () => Kanban.create(name: 'Unknown', topicId: ''),
    );

    // Build the ordered list of states. The "No State" column (empty
    // string key) is ALWAYS present and always last, even if the kanban
    // somehow ends up with no defined states. This is the fallback column
    // for any todo whose state no longer exists in `kanban.states`
    // (e.g. because the state was deleted).
    final List<String> allStates = List<String>.from(kanban.states);
    if (!allStates.contains(kTodoNoState)) {
      allStates.add(kTodoNoState);
    }

    // Group todos by state. "No State" (kTodoNoState / empty string) is
    // the catch-all: any todo whose state is empty, or whose state is
    // not in the current list of states, lands here. This is the
    // contract: deleting a state moves its todos to the empty string column.
    final Map<String, List<Todo>> todosByState = {
      for (final s in allStates) s: <Todo>[],
    };
    for (final todo in kanban.todos) {
      final stateKey = todo.state;
      if (stateKey.isEmpty || !todosByState.containsKey(stateKey)) {
        todosByState[kTodoNoState]!.add(todo);
      } else {
        todosByState[stateKey]!.add(todo);
      }
    }

    // Build columns in order: defined states first, then "No State" at the end.
    // `allStates` already includes the empty string at the end.
    final List<String> columnOrder = allStates;

    return Scaffold(
      appBar: AppBar(
        title: Text(kanban.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add State',
            onPressed: () => _showAddStateDialog(context, viewModel, kanban),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Rename Kanban',
            onPressed: () => _showRenameKanbanDialog(context, viewModel, kanban),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _confirmDeleteKanban(context, viewModel, kanban);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete Kanban'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Add todo to "No State" column bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Add todo to "No State"...',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        viewModel.addKanbanTodo(kanban.id, value.trim());
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // Could add a quick-add dialog here
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          // Kanban columns
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(8),
              children: columnOrder.map((stateName) {
                final todos = todosByState[stateName] ?? [];
                final isNoState = stateName == kTodoNoState;
                final displayName = isNoState ? 'No State' : stateName;
                final canDeleteState = !isNoState;
                final color = isNoState
                    ? Colors.grey[300]
                    : Colors.primaries[kanban.states.indexOf(stateName) % Colors.primaries.length].withValues(alpha: 0.1);

                return _KanbanColumn(
                  key: ValueKey(stateName),
                  stateName: stateName,
                  displayName: displayName,
                  todos: todos,
                  color: color!,
                  kanbanId: kanban.id,
                  canDeleteState: canDeleteState,
                  onAddTodo: (title) => viewModel.addKanbanTodo(kanban.id, title),
                  onToggleTodo: (todoId) => viewModel.toggleKanbanTodo(kanban.id, todoId),
                  onRemoveTodo: (todoId) => viewModel.removeKanbanTodo(kanban.id, todoId),
                  onMoveTodo: (todoId, newState) => viewModel.moveKanbanTodoToState(kanban.id, todoId, newState),
                  onRenameState: canDeleteState
                      ? (newName) => viewModel.renameKanbanState(kanban.id, stateName, newName)
                      : null,
                  onDeleteState: canDeleteState
                      ? () => _confirmDeleteState(context, viewModel, kanban, stateName)
                      : null,
                  allStates: kanban.states,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddStateDialog(
    BuildContext context,
    TopicDetailViewModel viewModel,
    Kanban kanban,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New State'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. In Review, Testing, Blocked',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                viewModel.addKanbanState(kanban.id, name);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showRenameKanbanDialog(
    BuildContext context,
    TopicDetailViewModel viewModel,
    Kanban kanban,
  ) {
    final controller = TextEditingController(text: kanban.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Kanban'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                viewModel.renameKanban(kanban.id, name);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteState(
    BuildContext context,
    TopicDetailViewModel viewModel,
    Kanban kanban,
    String stateName,
  ) {
    final todosInState = kanban.todos.where((t) => t.state == stateName).length;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "$stateName"?'),
        content: Text(
          'This will remove the state/column. '
          '${todosInState} todo(s) in this state will be moved to "No State".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              viewModel.removeKanbanState(kanban.id, stateName);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteKanban(
    BuildContext context,
    TopicDetailViewModel viewModel,
    Kanban kanban,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${kanban.name}"?'),
        content: const Text(
          'This will remove the kanban and all its todos. '
          'It will not affect the topic section todos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              viewModel.removeKanban(kanban.id);
              Navigator.pop(ctx);
              Navigator.pop(context); // Go back from KanbanView
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _KanbanColumn extends StatefulWidget {
  const _KanbanColumn({
    required this.stateName,
    required this.displayName,
    required this.todos,
    required this.color,
    required this.kanbanId,
    required this.canDeleteState,
    required this.onAddTodo,
    required this.onToggleTodo,
    required this.onRemoveTodo,
    required this.onMoveTodo,
    this.onRenameState,
    this.onDeleteState,
    required this.allStates,
    Key? key,
  }) : super(key: key);

  final String stateName;
  final String displayName;
  final List<Todo> todos;
  final Color color;
  final String kanbanId;
  final bool canDeleteState;
  final void Function(String title) onAddTodo;
  final void Function(String todoId) onToggleTodo;
  final void Function(String todoId) onRemoveTodo;
  final void Function(String todoId, String newState) onMoveTodo;
  final void Function(String newName)? onRenameState;
  final void Function()? onDeleteState;
  final List<String> allStates;

  @override
  State<_KanbanColumn> createState() => _KanbanColumnState();
}

class _KanbanColumnState extends State<_KanbanColumn> {
  final TextEditingController _todoController = TextEditingController();

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Column header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  '${widget.todos.length}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                if (widget.canDeleteState) ...[
                  const SizedBox(width: 4),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onSelected: (value) {
                      if (value == 'rename' && widget.onRenameState != null) {
                        _showRenameStateDialog(context);
                      } else if (value == 'delete' && widget.onDeleteState != null) {
                        widget.onDeleteState!();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'rename',
                        child: Text('Rename'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete State'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Todo list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: widget.todos.length + 1, // +1 for add button
              itemBuilder: (context, index) {
                if (index == widget.todos.length) {
                  // Add todo button at bottom
                  return _buildAddTodoField();
                }
                final todo = widget.todos[index];
                return _buildTodoCard(todo);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddTodoField() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _todoController,
                decoration: const InputDecoration(
                  hintText: 'Add todo...',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    widget.onAddTodo(value.trim());
                    _todoController.clear();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                if (_todoController.text.trim().isNotEmpty) {
                  widget.onAddTodo(_todoController.text.trim());
                  _todoController.clear();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoCard(Todo todo) {
    final availableStates = [kTodoNoState, ...widget.allStates];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: todo.isDone,
                  onChanged: (_) => widget.onToggleTodo(todo.id),
                ),
                Expanded(
                  child: Text(
                    todo.title,
                    style: TextStyle(
                      decoration: todo.isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 18),
                  onSelected: (value) {
                    if (value == 'delete') {
                      widget.onRemoveTodo(todo.id);
                    } else if (value.startsWith('move:')) {
                      final newState = value.substring(5);
                      widget.onMoveTodo(todo.id, newState);
                    }
                  },
                  itemBuilder: (context) {
                    final items = <PopupMenuEntry<String>>[];
                    // Move to state options
                    for (final state in availableStates) {
                      if (state != todo.state) {
                        items.add(
                          PopupMenuItem(
                            value: 'move:$state',
                            child: Text(state == kTodoNoState ? 'Move to No State' : 'Move to $state'),
                          ),
                        );
                      }
                    }
                    items.add(const PopupMenuDivider());
                    items.add(
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    );
                    return items;
                  },
                ),
              ],
            ),
            // State indicator
            if (todo.state.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 40, top: 4),
                child: Chip(
                  label: Text(todo.state, style: const TextStyle(fontSize: 11)),
                  backgroundColor: Colors.blue.withValues(alpha: 0.1),
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showRenameStateDialog(BuildContext context) {
    final controller = TextEditingController(text: widget.stateName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename State'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty && widget.onRenameState != null) {
                widget.onRenameState!(name);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}