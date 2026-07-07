import 'package:emoapp/model/analysis_prompt.dart';
import 'package:emoapp/model/entity_base.dart';
import 'package:emoapp/view_model/analysis_prompt_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AnalysisPromptListView extends StatefulWidget {
  const AnalysisPromptListView({Key? key}) : super(key: key);

  @override
  _AnalysisPromptListViewState createState() => _AnalysisPromptListViewState();
}

class _AnalysisPromptListViewState extends State<AnalysisPromptListView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Prompts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnalysisPromptEditView(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<AnalysisPromptViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.prompts.isEmpty) {
            return const Center(
              child: Text('No analysis prompts yet. Create one!'),
            );
          }

          return ListView.builder(
            itemCount: viewModel.prompts.length,
            itemBuilder: (context, index) {
              final prompt = viewModel.prompts[index];
              return ListTile(
                title: Text(prompt.name),
                subtitle: Text(prompt.description),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AnalysisPromptEditView(prompt: prompt),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Prompt'),
                        content: const Text('Are you sure you want to delete this prompt?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await viewModel.deletePrompt(prompt.id);
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
    );
  }
}

class AnalysisPromptEditView extends StatefulWidget {
  final AnalysisPrompt? prompt;

  const AnalysisPromptEditView({Key? key, this.prompt}) : super(key: key);

  @override
  _AnalysisPromptEditViewState createState() => _AnalysisPromptEditViewState();
}

class _AnalysisPromptEditViewState extends State<AnalysisPromptEditView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _promptTemplateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.prompt != null) {
      _nameController.text = widget.prompt!.name;
      _descriptionController.text = widget.prompt!.description;
      _promptTemplateController.text = widget.prompt!.promptTemplate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _promptTemplateController.dispose();
    super.dispose();
  }

  Future<void> _savePrompt() async {
    if (_formKey.currentState!.validate()) {
      final viewModel = context.read<AnalysisPromptViewModel>();
      final prompt = AnalysisPrompt(
        id: widget.prompt?.id ?? EntityBase.generateId(),
        name: _nameController.text,
        description: _descriptionController.text,
        promptTemplate: _promptTemplateController.text,
        createdAt: widget.prompt?.createdAt ?? DateTime.now().millisecondsSinceEpoch,
      );

      if (widget.prompt == null) {
        await viewModel.addPrompt(prompt);
      } else {
        await viewModel.updatePrompt(prompt);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.prompt == null ? 'Create Prompt' : 'Edit Prompt'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _promptTemplateController,
                decoration: const InputDecoration(
                  labelText: 'Prompt Template',
                  border: OutlineInputBorder(),
                  hintText: 'Use {{entries}} placeholder for journal entries content',
                ),
                maxLines: 10,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a prompt template';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _savePrompt,
                child: const Text('Save Prompt'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
