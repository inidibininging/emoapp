import 'package:emoapp/model/journal_colors.dart' as JournalColors;
import 'package:emoapp/view_model/mindmap_view_model.dart';
import 'package:emoapp/view_model/kanban_list_view_model.dart';
import 'package:emoapp/view_model/ollama_config_view_model.dart';
import 'package:emoapp/view_model/analysis_prompt_view_model.dart';
import 'package:emoapp/view_model/journal_analysis_view_model.dart';
import 'package:emoapp/view_model/journal_entry_extended_list_view_model.dart';
import 'package:emoapp/view_model/app_settings_view_model.dart';
import 'package:emoapp/widgets/topic_list_view.dart';
import 'package:emoapp/widgets/journal_calendar.dart';
import 'package:emoapp/widgets/mindmap/mindmap_screen.dart';
import 'package:emoapp/widgets/kanban_list_view.dart';
import 'package:emoapp/widgets/ollama_settings_view.dart';
import 'package:emoapp/widgets/analysis_prompt_list_view.dart';
import 'package:emoapp/widgets/journal_analysis_view.dart';
import 'package:emoapp/widgets/app_settings_view.dart';
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
            ListTile(
              title: const Text('Kanbans'),
              leading: const Icon(Icons.view_kanban),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedIndex = 3;
                });
              },
            ),
            ListTile(
              title: const Text('App Settings'),
              leading: const Icon(Icons.settings_applications),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider(
                      create: (_) => AppSettingsViewModel(),
                      child: const AppSettingsView(),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Ollama Settings'),
              leading: const Icon(Icons.settings),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider(
                      create: (_) => OllamaConfigViewModel(),
                      child: const OllamaSettingsView(),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Analysis Prompts'),
              leading: const Icon(Icons.analytics),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider(
                      create: (_) => AnalysisPromptViewModel(),
                      child: const AnalysisPromptListView(),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Journal Analysis'),
              leading: const Icon(Icons.assessment),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MultiProvider(
                      providers: [
                        ChangeNotifierProvider(create: (_) => JournalAnalysisViewModel()),
                        ChangeNotifierProvider(create: (_) => JournalEntryExtendedListViewModel()),
                      ],
                      child: const JournalAnalysisView(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          TopicListView(),
          JournalCalendar(),
          ChangeNotifierProvider(
            create: (_) => MindmapViewModel(),
            child: const MindmapScreen(),
          ),
          ChangeNotifierProvider(
            create: (_) => KanbanListViewModel(),
            child: const KanbanListView(),
          ),
        ],
      ),
    );
  }
}
