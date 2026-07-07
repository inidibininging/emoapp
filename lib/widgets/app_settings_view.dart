import 'package:emoapp/model/app_settings.dart';
import 'package:emoapp/view_model/app_settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppSettingsView extends StatefulWidget {
  const AppSettingsView({Key? key}) : super(key: key);

  @override
  _AppSettingsViewState createState() => _AppSettingsViewState();
}

class _AppSettingsViewState extends State<AppSettingsView> {
  final _formKey = GlobalKey<FormState>();
  final _pocketbaseUrlController = TextEditingController();
  final _pocketbaseEmailController = TextEditingController();
  final _pocketbasePasswordController = TextEditingController();
  final _storageLocationController = TextEditingController();
  final _ollamaBaseUrlController = TextEditingController();
  final _ollamaDefaultModelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = context.read<AppSettingsViewModel>().currentSettings;
    if (settings != null) {
      _pocketbaseUrlController.text = settings.pocketbaseUrl;
      _pocketbaseEmailController.text = settings.pocketbaseEmail;
      _pocketbasePasswordController.text = settings.pocketbasePassword;
      _storageLocationController.text = settings.storageLocation;
      _ollamaBaseUrlController.text = settings.ollamaBaseUrl;
      _ollamaDefaultModelController.text = settings.defaultOllamaModel;
    }
  }

  @override
  void dispose() {
    _pocketbaseUrlController.dispose();
    _pocketbaseEmailController.dispose();
    _pocketbasePasswordController.dispose();
    _storageLocationController.dispose();
    _ollamaBaseUrlController.dispose();
    _ollamaDefaultModelController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final viewModel = context.read<AppSettingsViewModel>();
    final currentSettings = viewModel.currentSettings;
    
    if (currentSettings != null) {
      final updatedSettings = AppSettings(
        id: currentSettings.id,
        backendType: currentSettings.backendType,
        pocketbaseUrl: _pocketbaseUrlController.text,
        pocketbaseEmail: _pocketbaseEmailController.text,
        pocketbasePassword: _pocketbasePasswordController.text,
        storageLocation: _storageLocationController.text,
        enableAutoBackup: currentSettings.enableAutoBackup,
        backupFrequencyDays: currentSettings.backupFrequencyDays,
        lastBackupTimestamp: currentSettings.lastBackupTimestamp,
        enableAnalytics: currentSettings.enableAnalytics,
        themeMode: currentSettings.themeMode,
        enableOllamaIntegration: currentSettings.enableOllamaIntegration,
        ollamaBaseUrl: _ollamaBaseUrlController.text,
        defaultOllamaModel: _ollamaDefaultModelController.text,
        showAdvancedSettings: currentSettings.showAdvancedSettings,
      );
      
      await viewModel.updateSettings(updatedSettings);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettingsViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading || viewModel.currentSettings == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('App Settings')),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final settings = viewModel.currentSettings!;

        return Scaffold(
          appBar: AppBar(
            title: const Text('App Settings'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Backend Settings Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Backend Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          
                          DropdownButtonFormField<BackendType>(
                            value: settings.backendType,
                            decoration: const InputDecoration(
                              labelText: 'Backend Type',
                              border: OutlineInputBorder(),
                            ),
                            items: BackendType.values.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(_getBackendTypeName(type)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                viewModel.updateBackendType(value);
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          if (settings.backendType == BackendType.pocketbase) ...[
                            TextFormField(
                              controller: _pocketbaseUrlController,
                              decoration: const InputDecoration(
                                labelText: 'PocketBase URL',
                                hintText: 'https://your-pocketbase-server.com',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (settings.backendType == BackendType.pocketbase && 
                                    (value == null || value.isEmpty)) {
                                  return 'Please enter PocketBase URL';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _pocketbaseEmailController,
                              decoration: const InputDecoration(
                                labelText: 'PocketBase Email',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _pocketbasePasswordController,
                              decoration: const InputDecoration(
                                labelText: 'PocketBase Password',
                                border: OutlineInputBorder(),
                              ),
                              obscureText: true,
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () async {
                                // Test PocketBase connection
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Testing PocketBase connection...')),
                                );
                                
                                // TODO: Implement actual PocketBase connection test
                                await Future.delayed(const Duration(seconds: 2));
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Connection test completed')),
                                );
                              },
                              child: const Text('Test Connection'),
                            ),
                          ],
                          
                          if (settings.backendType == BackendType.localStorage) ...[
                            TextFormField(
                              controller: _storageLocationController,
                              decoration: const InputDecoration(
                                labelText: 'Storage Location',
                                hintText: 'Custom storage path (leave empty for default)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                // TODO: Implement file picker for storage location
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('File picker would open here')),
                                );
                              },
                              child: const Text('Browse'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Ollama Integration Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('Ollama Integration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const Spacer(),
                              Switch(
                                value: settings.enableOllamaIntegration,
                                onChanged: (value) {
                                  viewModel.updateOllamaSettings(
                                    value,
                                    settings.ollamaBaseUrl,
                                    settings.defaultOllamaModel
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          if (settings.enableOllamaIntegration) ...[
                            TextFormField(
                              controller: _ollamaBaseUrlController,
                              decoration: const InputDecoration(
                                labelText: 'Ollama Base URL',
                                hintText: 'http://localhost:11434',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (settings.enableOllamaIntegration && 
                                    (value == null || value.isEmpty)) {
                                  return 'Please enter Ollama base URL';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _ollamaDefaultModelController,
                              decoration: const InputDecoration(
                                labelText: 'Default Model',
                                hintText: 'llama3, mistral, etc.',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () async {
                                // Test Ollama connection
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Testing Ollama connection...')),
                                );
                                
                                // TODO: Implement actual Ollama connection test
                                await Future.delayed(const Duration(seconds: 2));
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Ollama connection test completed')),
                                );
                              },
                              child: const Text('Test Ollama Connection'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // App Settings Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('App Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          
                          DropdownButtonFormField<String>(
                            value: settings.themeMode,
                            decoration: const InputDecoration(
                              labelText: 'Theme Mode',
                              border: OutlineInputBorder(),
                            ),
                            items: ['system', 'light', 'dark'].map((mode) {
                              return DropdownMenuItem(
                                value: mode,
                                child: Text(mode.capitalize()),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                viewModel.updateThemeMode(value);
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          Row(
                            children: [
                              const Text('Enable Auto Backup'),
                              const Spacer(),
                              Switch(
                                value: settings.enableAutoBackup,
                                onChanged: (value) {
                                  viewModel.updateBackupSettings(value, settings.backupFrequencyDays);
                                },
                              ),
                            ],
                          ),
                          
                          if (settings.enableAutoBackup) ...[
                            const SizedBox(height: 16),
                            Slider(
                              value: settings.backupFrequencyDays.toDouble(),
                              min: 1,
                              max: 30,
                              divisions: 29,
                              label: '${settings.backupFrequencyDays} days',
                              onChanged: (value) {
                                viewModel.updateBackupSettings(true, value.toInt());
                              },
                            ),
                            Text('Backup frequency: ${settings.backupFrequencyDays} days'),
                          ],
                          const SizedBox(height: 16),
                          
                          Row(
                            children: [
                              const Text('Enable Analytics'),
                              const Spacer(),
                              Switch(
                                value: settings.enableAnalytics,
                                onChanged: (value) {
                                  final updatedSettings = AppSettings(
                                    id: settings.id,
                                    backendType: settings.backendType,
                                    pocketbaseUrl: settings.pocketbaseUrl,
                                    pocketbaseEmail: settings.pocketbaseEmail,
                                    pocketbasePassword: settings.pocketbasePassword,
                                    storageLocation: settings.storageLocation,
                                    enableAutoBackup: settings.enableAutoBackup,
                                    backupFrequencyDays: settings.backupFrequencyDays,
                                    lastBackupTimestamp: settings.lastBackupTimestamp,
                                    enableAnalytics: value,
                                    themeMode: settings.themeMode,
                                    enableOllamaIntegration: settings.enableOllamaIntegration,
                                    ollamaBaseUrl: settings.ollamaBaseUrl,
                                    defaultOllamaModel: settings.defaultOllamaModel,
                                    showAdvancedSettings: settings.showAdvancedSettings,
                                  );
                                  viewModel.updateSettings(updatedSettings);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  ElevatedButton(
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Save All Settings'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getBackendTypeName(BackendType type) {
    switch (type) {
      case BackendType.localStorage:
        return 'Local Storage';
      case BackendType.pocketbase:
        return 'PocketBase';
      case BackendType.firebase:
        return 'Firebase';
      case BackendType.custom:
        return 'Custom';
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
