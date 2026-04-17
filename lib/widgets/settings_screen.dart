import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:emoapp/view_model/settings_view_model.dart';

/// Settings screen for configuring app storage and database
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Don't show settings on web
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: const Center(
          child: Text('Settings are not available on web platform'),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => SettingsViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: const _SettingsBody(),
      ),
    );
  }
}

class _SettingsBody extends StatelessWidget {
  const _SettingsBody();

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, viewModel, _) => SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Storage Settings Section
            _buildSectionHeader('Storage Settings'),
            const SizedBox(height: 12),

            // Current Storage Path
            _buildStoragePathCard(viewModel),
            const SizedBox(height: 16),

            // Action Buttons
            _buildActionButtons(context, viewModel),
            const SizedBox(height: 24),

            // Ollama Configuration Section
            _buildSectionHeader('Ollama Configuration'),
            const SizedBox(height: 12),
            _buildOllamaSettings(context, viewModel),
            const SizedBox(height: 24),

            // Status Messages
            if (viewModel.statusMessage.isNotEmpty)
              _buildStatusMessage(context, viewModel),

            const SizedBox(height: 24),

            // Info Section
            _buildInfoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildOllamaSettings(
      BuildContext context, SettingsViewModel viewModel) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Host Input
            TextField(
              decoration: InputDecoration(
                labelText: 'Ollama Host',
                hintText: 'e.g., http://localhost',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.dns),
              ),
              controller: TextEditingController(text: viewModel.ollamaHost),
              onChanged: (value) => viewModel.setOllamaHost(value),
            ),
            const SizedBox(height: 16),

            // Port Input
            TextField(
              decoration: InputDecoration(
                labelText: 'Ollama Port',
                hintText: 'e.g., 11434',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.numbers),
              ),
              keyboardType: TextInputType.number,
              controller:
                  TextEditingController(text: viewModel.ollamaPort.toString()),
              onChanged: (value) {
                final port = int.tryParse(value);
                if (port != null) {
                  viewModel.setOllamaPort(port);
                }
              },
            ),
            const SizedBox(height: 16),

            // Test Connection & Fetch Models Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: viewModel.isLoading
                        ? null
                        : () => viewModel.testOllamaConnection(),
                    icon: const Icon(Icons.link),
                    label: const Text('Test Connection'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: viewModel.isLoading
                        ? null
                        : () => viewModel.fetchAvailableModels(),
                    icon: const Icon(Icons.cloud_download),
                    label: const Text('Fetch Models'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Model Selection Dropdown
            if (viewModel.availableModels.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Model',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: viewModel.ollamaModel.isEmpty
                          ? viewModel.availableModels.first
                          : viewModel.ollamaModel,
                      items: viewModel.availableModels
                          .map(
                            (model) => DropdownMenuItem(
                              value: model,
                              child: Text(model),
                            ),
                          )
                          .toList(),
                      onChanged: (model) {
                        if (model != null) {
                          viewModel.setOllamaModel(model);
                        }
                      },
                    ),
                  ),
                ],
              )
            else if (viewModel.availableModels.isEmpty &&
                viewModel.statusMessage.isEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Click "Fetch Models" to load available models from Ollama',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            // Loading Indicator
            if (viewModel.isLoading) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStoragePathCard(SettingsViewModel viewModel) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Storage Path',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  viewModel.currentStoragePath,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, SettingsViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Auto-reload checkbox
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Checkbox(
                value: viewModel.autoReloadDatabaseOnFolderChange,
                onChanged: (value) {
                  if (value != null) {
                    viewModel.setAutoReloadDatabaseOnFolderChange(value);
                  }
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Auto-reload database',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Automatically reload entries when changing folder',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Select Directory Button
        ElevatedButton.icon(
          onPressed: viewModel.isLoading
              ? null
              : () => viewModel.selectStorageDirectory(),
          icon: const Icon(Icons.folder_open),
          label: const Text('Select Storage Directory'),
        ),
        const SizedBox(height: 12),

        // Reload Database Button
        ElevatedButton.icon(
          onPressed: viewModel.isLoading
              ? null
              : () => viewModel.reloadDatabaseFromDirectory(),
          icon: const Icon(Icons.refresh),
          label: const Text('Reload Database Entries'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 12),

        // Reset to Default Button
        ElevatedButton.icon(
          onPressed: viewModel.isLoading
              ? null
              : () => _showResetConfirmation(context, viewModel),
          icon: const Icon(Icons.restore),
          label: const Text('Reset to Default'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
          ),
        ),

        // Loading Indicator
        if (viewModel.isLoading) ...[
          const SizedBox(height: 12),
          const LinearProgressIndicator(),
        ],
      ],
    );
  }

  Widget _buildStatusMessage(
      BuildContext context, SettingsViewModel viewModel) {
    final isError = viewModel.statusMessage.contains('Error') ||
        viewModel.statusMessage.contains('denied') ||
        viewModel.statusMessage.contains('cancelled');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? Colors.red[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isError ? Colors.red[300]! : Colors.green[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isError ? Icons.error : Icons.check_circle,
                color: isError ? Colors.red : Colors.green,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  viewModel.statusMessage,
                  style: TextStyle(
                    fontSize: 13,
                    color: isError ? Colors.red[900] : Colors.green[900],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => viewModel.clearStatusMessage(),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      elevation: 1,
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info, color: Colors.blue),
                SizedBox(width: 12),
                Text(
                  'About Storage',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'The app stores all database entries as JSON files organized by entity type. You can:\n\n'
              '• Select a custom directory to store your database files\n'
              '• Reload all database entries from the current directory\n'
              '• Reset to the default storage location in the app documents folder\n\n'
              'Note: This feature is not available on web platform.',
              style: TextStyle(fontSize: 13, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetConfirmation(
    BuildContext context,
    SettingsViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Default?'),
        content: const Text(
          'This will reset the storage directory to the default location in the app documents folder.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              viewModel.resetToDefaultDirectory();
              Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
