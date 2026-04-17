import 'package:emoapp/model/journal_colors.dart' as JournalColors;
import 'package:emoapp/view_model/mindmap_view_model.dart';
import 'package:emoapp/widgets/topic_list_view.dart';
import 'package:emoapp/widgets/journal_calendar.dart';
import 'package:emoapp/widgets/mindmap/mindmap_screen.dart';
import 'package:emoapp/widgets/settings_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EMO APP'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: JournalColors.primaryColor,
              ),
              child: Text(
                'Navigation',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              title: const Text('Topics'),
              leading: const Icon(Icons.bookmark),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedIndex = 0;
                });
              },
            ),
            ListTile(
              title: const Text('Calendar'),
              leading: const Icon(Icons.calendar_month),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedIndex = 1;
                });
              },
            ),
            ListTile(
              title: const Text('Mindmap'),
              leading: const Icon(Icons.schema),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedIndex = 2;
                });
              },
            ),
            if (!kIsWeb)
              ListTile(
                title: const Text('Settings'),
                leading: const Icon(Icons.settings),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedIndex = 3;
                  });
                },
              ),
          ],
        ),
      ),
      body: _selectedIndex == 3 && !kIsWeb
          ? const SettingsScreen()
          : IndexedStack(
              index: _selectedIndex,
              children: [
                TopicListView(),
                JournalCalendar(),
                ChangeNotifierProvider(
                  create: (_) => MindmapViewModel(),
                  child: const MindmapScreen(),
                ),
              ],
            ),
    );
  }
}
