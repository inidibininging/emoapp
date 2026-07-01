import 'package:emoapp/model/kanban.dart';
import 'package:emoapp/model/topic.dart';
import 'package:emoapp/services/flat_file_service.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class KanbanListViewModel extends ChangeNotifier {
  List<Topic> _topics = [];
  List<Topic> get topics => _topics;

  // Flattened list of kanbans with topic info for display
  List<_KanbanWithTopic> get kanbansWithTopic {
    final List<_KanbanWithTopic> list = [];
    for (final topic in _topics) {
      for (final kanban in topic.kanbans) {
        list.add(_KanbanWithTopic(topic: topic, kanban: kanban));
      }
    }
    return list;
  }

  KanbanListViewModel() {
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    final service = GetIt.instance.get<FlatFileEntityService<Topic>>();
    final topics = await service.getAll();
    _topics = topics.where((t) => t.id.isNotEmpty).toList();
    notifyListeners();
  }

  Future<void> refresh() async {
    await _loadTopics();
  }
}

class _KanbanWithTopic {
  final Topic topic;
  final Kanban kanban;
  _KanbanWithTopic({required this.topic, required this.kanban});
}