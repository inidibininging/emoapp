import 'package:emoapp/model/discussion.dart';
import 'package:emoapp/model/journal_colors.dart';
import 'package:emoapp/services/entity_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:get_it/get_it.dart';
import 'package:emoapp/model/profile.dart';

class DiscussionLobby extends StatefulWidget {
  const DiscussionLobby({
    required this.discussions,
    super.key,
  });

  final EntityService<Discussion, DiscussionAdapter> discussions;

  @override
  State<StatefulWidget> createState() => _DiscussionLobby();
}

class _DiscussionLobby extends State<DiscussionLobby> {
  String _selectedIndex = '';

  Future<void> _updateSelectedDiscussion(String id) async {
    //save to debug profile
    final profiles =
        GetIt.instance.get<EntityService<Profile, ProfileAdapter>>();
    final debugProfile = await profiles
        .where((m) => m.name == 'debug')
        .then((pps) => pps.firstOrNull);
    debugProfile?.currentDiscussionId = id;
    await debugProfile?.save();

    _selectedIndex = id;
  }

  Future<List<Widget>> getChildren() async {
    final d = await widget.discussions.getAll().then(
          (discussions) => discussions.map(
            (d) => ListTile(
              leading: const Icon(
                Icons.message,
                size: 32,
              ),
              title: Text(d.name),
              selected: _selectedIndex == d.id,
              onTap: () async {
                await _updateSelectedDiscussion(d.id);
                setState(() {});
                // Navigator.pop(context);
              },
            ),
          ),
        );
    return [
      DrawerHeader(
          decoration: const BoxDecoration(
            color: gradientColor,
          ),
          child: ListView(
            shrinkWrap: true,
            // padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            children: [
              const Text('Discussions'),
              // TextEditingController(text: 'search for any discussion'),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: IconButton(
                        // key: UniqueKey(),
                        // heroTag: 'destroy all',
                        onPressed: () async {
                          await widget.discussions.create(
                            Discussion(
                                name: 'New',
                                imageKey: '',
                                description: '',
                                id: const Uuid().v4(),
                                children1: []),
                            (Discussion d) => (true, null),
                          );
                          setState(() {});
                        },
                        icon: const Icon(
                          Icons.add,
                          size: 48,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: IconButton(
                        // key: UniqueKey(),
                        // heroTag: 'destroy all',
                        onPressed: () async {
                          setState(() {});
                        },
                        icon: const Icon(
                          Icons.delete_forever,
                          size: 48,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          )),
    ].cast<Widget>().followedBy(d).toList();
  }

  @override
  Widget build(BuildContext context) => Drawer(
        child: FutureBuilder<List<Widget>>(
          initialData: const <Widget>[],
          future: getChildren(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }
            return ListView(
              padding: EdgeInsets.zero,
              children: snapshot.data!,
            );
          },
        ),
      );
}
