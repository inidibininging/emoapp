import 'package:emoapp/model/entity_base.dart';
import 'package:emoapp/model/journal_analysis.dart';
import 'package:emoapp/model/journal_entry_extended.dart';
import 'package:emoapp/view_model/journal_analysis_view_model.dart';
import 'package:emoapp/view_model/journal_entry_extended_list_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class JournalAnalysisView extends StatefulWidget {
  const JournalAnalysisView({Key? key}) : super(key: key);

  @override
  _JournalAnalysisViewState createState() => _JournalAnalysisViewState();
}

class _JournalAnalysisViewState extends State<JournalAnalysisView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Analyses'),
      ),
      body: Consumer<JournalAnalysisViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.analyses.isEmpty) {
            return const Center(
              child: Text('No analyses yet. Create one!'),
            );
          }

          return ListView.builder(
            itemCount: viewModel.analyses.length,
            itemBuilder: (context, index) {
              final analysis = viewModel.analyses[index];
              return ListTile(
                title: Text('Analysis ${index + 1}'),
                subtitle: Text('Prompt ID: ${analysis.promptId}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JournalAnalysisDetailView(analysis: analysis),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Analysis'),
                        content: const Text('Are you sure you want to delete this analysis?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await viewModel.deleteAnalysis(analysis.id);
                              Navigator.pop(context);
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const JournalAnalysisCreateView(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class JournalAnalysisCreateView extends StatefulWidget {
  const JournalAnalysisCreateView({Key? key}) : super(key: key);

  @override
  _JournalAnalysisCreateViewState createState() => _JournalAnalysisCreateViewState();
}

class _JournalAnalysisCreateViewState extends State<JournalAnalysisCreateView> {
  String? _selectedPromptId;
  final List<String> _selectedEntryIds = [];
  List<JournalEntryExtended> _allEntries = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);
    try {
      final entryViewModel = context.read<JournalEntryExtendedListViewModel>();
      final entries = await entryViewModel.entries(null);
      setState(() => _allEntries = entries);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load entries: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createAnalysis() async {
    if (_selectedPromptId == null || _selectedEntryIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a prompt and at least one entry')),
      );
      return;
    }

    // In a real implementation, you would call Ollama API here
    // For now, we'll create a placeholder analysis
    final analysis = JournalAnalysis(
      id: EntityBase.generateId(),
      promptId: _selectedPromptId!,
      entryIds: _selectedEntryIds,
      analysisResult: 'Analysis result would appear here after calling Ollama API',
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    final viewModel = context.read<JournalAnalysisViewModel>();
    await viewModel.addAnalysis(analysis);
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Analysis'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Prompt selection would go here
                  // For now, we'll just show entry selection
                  Expanded(
                    child: ListView.builder(
                      itemCount: _allEntries.length,
                      itemBuilder: (context, index) {
                        final entry = _allEntries[index];
                        final isSelected = _selectedEntryIds.contains(entry.id);
                        
                        return CheckboxListTile(
                          title: Text(entry.title.isNotEmpty ? entry.title : '(No title)'),
                          subtitle: Text(entry.text.isNotEmpty 
                              ? entry.text.substring(0, entry.text.length > 50 ? 50 : entry.text.length)
                              : '(No content)'),
                          value: isSelected,
                          onChanged: (selected) {
                            setState(() {
                              if (selected == true) {
                                _selectedEntryIds.add(entry.id);
                              } else {
                                _selectedEntryIds.remove(entry.id);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _createAnalysis,
                    child: const Text('Create Analysis'),
                  ),
                ],
              ),
            ),
    );
  }
}

class JournalAnalysisDetailView extends StatelessWidget {
  final JournalAnalysis analysis;

  const JournalAnalysisDetailView({Key? key, required this.analysis}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Prompt ID: ${analysis.promptId}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Text('Entries analyzed: ${analysis.entryIds.length}'),
            const SizedBox(height: 16),
            const Text('Analysis Result:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Text(analysis.analysisResult),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
