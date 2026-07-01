import 'package:emoapp/view_model/kanban_list_view_model.dart';
import 'package:emoapp/view_model/topic_detail_view_model.dart';
import 'package:emoapp/widgets/kanban_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class KanbanListView extends StatelessWidget {
  const KanbanListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider< KanbanListViewModel>(
      create: (_) => KanbanListViewModel(),
      child: Consumer<KanbanListViewModel>(
        builder: (context, viewModel, child) => Scaffold(
          appBar: AppBar(
            title: const Text('All Kanbans'),
          ),
          body: viewModel.kanbansWithTopic.isEmpty
              ? const Center(
                  child: Text(
                    'No kanbans found. Create some in your topics first!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: viewModel.kanbansWithTopic.length,
                  itemBuilder: (context, index) {
                    final item = viewModel.kanbansWithTopic[index];
                    final kanban = item.kanban;
                    final topic = item.topic;
                    final completed = kanban.todos.where((t) => t.isDone).length;
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.view_kanban),
                        title: Text(kanban.name),
                        subtitle: Text(
                          'In topic: ${topic.title}\n'
                          '$completed/${kanban.todos.length} todos completed',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => ChangeNotifierProvider.value(
                              value: TopicDetailViewModel(topic),
                              child: KanbanView(kanbanId: kanban.id),
                            ),
                          ));
                        },
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Navigate to topics to add kanban there
              Navigator.of(context).pushNamed('/topics');
            },
            tooltip: 'Add Kanban via Topics',
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}