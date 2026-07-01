import 'package:emoapp/model/kanban.dart';
import 'package:emoapp/model/todo.dart';
import 'package:emoapp/view_model/topic_detail_view_model.dart';
import 'package:emoapp/widgets/kanban_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A section that shows all kanbans attached to a topic.
///
/// Each kanban has:
///   - a renameable name (header)
///   - a per-kanban list of todos (independent from the topic's flat todos)
///   - controls to add a new todo, toggle, or delete
///
/// The whole section also has an "Add Kanban" button to create a new board.
class KanbanSection extends StatelessWidget {
  const KanbanSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TopicDetailViewModel>();
    final kanbans = viewModel.kanbans;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Kanbans',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _showAddKanbanDialog(context, viewModel),
              icon: const Icon(Icons.add),
              label: const Text('Add Kanban'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (kanbans.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No kanbans yet. Create one to organize todos.'),
          )
        else
          Column(
            children: kanbans
                .map((k) => _KanbanCard(kanban: k))
                .toList(),
          ),
      ],
    );
  }

  void _showAddKanbanDialog(
    BuildContext context,
    TopicDetailViewModel viewModel,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Kanban'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. To Do, In Progress, Done',
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
                viewModel.addKanban(name);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _KanbanCard extends StatefulWidget {
  const _KanbanCard({required this.kanban, Key? key}) : super(key: key);

  final Kanban kanban;

  @override
  State<_KanbanCard> createState() => _KanbanCardState();
}

class _KanbanCardState extends State<_KanbanCard> {
  final TextEditingController _todoController = TextEditingController();

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watching the whole model keeps the card in sync when the underlying
    // list changes (add/toggle/remove).
    final viewModel = context.watch<TopicDetailViewModel>();
    final kanban = viewModel.kanbans.firstWhere(
      (k) => k.id == widget.kanban.id,
      orElse: () => widget.kanban,
    );
    final completed = kanban.todos.where((t) => t.isDone).length;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    kanban.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                Text(
                  '$completed/${kanban.todos.length}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                IconButton(
                  icon: const Icon(Icons.view_kanban, size: 18),
                  tooltip: 'Open Kanban View',
                  onPressed: () {
                    // Re-provide the existing view model to the pushed route,
                    // since Navigator.push places the new route outside the
                    // ChangeNotifierProvider scope created in TopicDetailView.
                    final vm = viewModel;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider<TopicDetailViewModel>.value(
                          value: vm,
                          child: KanbanView(kanbanId: kanban.id),
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  tooltip: 'Rename',
                  onPressed: () =>
                      _showRenameDialog(context, viewModel, kanban),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18),
                  tooltip: 'Delete Kanban',
                  onPressed: () => _confirmDeleteKanban(
                    context,
                    viewModel,
                    kanban,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _todoController,
                    decoration: const InputDecoration(
                      hintText: 'Add a todo to this kanban...',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final t = _todoController.text.trim();
                    if (t.isNotEmpty) {
                      viewModel.addKanbanTodo(kanban.id, t);
                      _todoController.clear();
                    }
                  },
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (kanban.todos.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('No todos in this kanban'),
              )
            else
              ...kanban.todos.map((todo) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Checkbox(
                          value: todo.isDone,
                          onChanged: (_) =>
                              viewModel.toggleKanbanTodo(kanban.id, todo.id),
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
                        _StateChip(
                          currentState: todo.state,
                          states: kanban.states,
                          onChanged: (newState) => viewModel
                              .moveKanbanTodoToState(
                                  kanban.id, todo.id, newState),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 18),
                          onPressed: () => viewModel
                              .removeKanbanTodo(kanban.id, todo.id),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(
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
          decoration: const InputDecoration(
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
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// A small clickable chip showing a todo's current state/column.
/// Tap to change state via a bottom sheet picker. Mirrors the column
/// colors used in the full KanbanView so it reads as the same board.
class _StateChip extends StatelessWidget {
  const _StateChip({
    required this.currentState,
    required this.states,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  final String currentState;
  final List<String> states;
  final void Function(String newState) onChanged;

  @override
  Widget build(BuildContext context) {
    // "No State" is always an option, matching the full KanbanView contract.
    final isNoState = currentState.isEmpty;
    final displayName = isNoState ? 'No State' : currentState;
    final colorIndex = isNoState
        ? -1
        : states.indexOf(currentState);
    final color = isNoState
        ? Colors.grey[300]
        : Colors
            .primaries[colorIndex % Colors.primaries.length]
            .withValues(alpha: 0.25);

    return ActionChip(
      label: Text(
        displayName,
        style: const TextStyle(fontSize: 12),
      ),
      avatar: Icon(
        isNoState ? Icons.help_outline : Icons.label_outline,
        size: 14,
      ),
      backgroundColor: color,
      tooltip: 'Change state',
      onPressed: () => _showStatePicker(context),
    );
  }

  void _showStatePicker(BuildContext context) {
    // Build options: defined states (in order) plus "No State" at the end.
    final allOptions = <String>[...states];
    if (!allOptions.contains(kTodoNoState)) {
      allOptions.add(kTodoNoState);
    }

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Move to state',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ...allOptions.map((s) {
              final isNoState = s == kTodoNoState;
              final displayName = isNoState ? 'No State' : s;
              final isCurrent = s == currentState;
              return ListTile(
                dense: true,
                leading: Icon(
                  isCurrent
                      ? Icons.check_circle
                      : (isNoState ? Icons.help_outline : Icons.label_outline),
                  color: isCurrent ? Colors.green : null,
                ),
                title: Text(displayName),
                enabled: !isCurrent,
                onTap: isCurrent
                    ? null
                    : () {
                        Navigator.pop(ctx);
                        onChanged(s);
                      },
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
