import 'package:emoapp/model/ollama_config.dart';
import 'package:emoapp/view_model/ollama_config_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OllamaSettingsView extends StatefulWidget {
  const OllamaSettingsView({Key? key}) : super(key: key);

  @override
  _OllamaSettingsViewState createState() => _OllamaSettingsViewState();
}

class _OllamaSettingsViewState extends State<OllamaSettingsView> {
  final _formKey = GlobalKey<FormState>();
  final _systemPromptController = TextEditingController();
  final _modelController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _topPController = TextEditingController();
  final _maxTokensController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final config = context.read<OllamaConfigViewModel>().currentConfig;
    if (config != null) {
      _systemPromptController.text = config.systemPrompt;
      _modelController.text = config.model;
      _temperatureController.text = config.temperature.toString();
      _topPController.text = config.topP.toString();
      _maxTokensController.text = config.maxTokens.toString();
    }
  }

  @override
  void dispose() {
    _systemPromptController.dispose();
    _modelController.dispose();
    _temperatureController.dispose();
    _topPController.dispose();
    _maxTokensController.dispose();
    super.dispose();
  }

  Future<void> _saveConfig() async {
    if (_formKey.currentState!.validate()) {
      final viewModel = context.read<OllamaConfigViewModel>();
      final currentConfig = viewModel.currentConfig;
      
      if (currentConfig != null) {
        final updatedConfig = OllamaConfig(
          id: currentConfig.id,
          systemPrompt: _systemPromptController.text,
          model: _modelController.text,
          temperature: double.parse(_temperatureController.text),
          topP: double.parse(_topPController.text),
          maxTokens: int.parse(_maxTokensController.text),
        );
        
        await viewModel.updateConfig(updatedConfig);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ollama configuration saved!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ollama Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _systemPromptController,
                decoration: const InputDecoration(
                  labelText: 'System Prompt',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a system prompt';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Model',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a model name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _temperatureController,
                decoration: const InputDecoration(
                  labelText: 'Temperature',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a temperature value';
                  }
                  final temp = double.tryParse(value);
                  if (temp == null || temp < 0 || temp > 1) {
                    return 'Please enter a value between 0 and 1';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _topPController,
                decoration: const InputDecoration(
                  labelText: 'Top P',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a top P value';
                  }
                  final topP = double.tryParse(value);
                  if (topP == null || topP < 0 || topP > 1) {
                    return 'Please enter a value between 0 and 1';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _maxTokensController,
                decoration: const InputDecoration(
                  labelText: 'Max Tokens',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter max tokens';
                  }
                  final tokens = int.tryParse(value);
                  if (tokens == null || tokens <= 0) {
                    return 'Please enter a positive integer';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveConfig,
                child: const Text('Save Configuration'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
