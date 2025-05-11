import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api/notification_manager.dart';
import '../../../services/models/notification_models.dart' as models;
import '../providers/notification_provider.dart';

class NotificationSettingsModal extends ConsumerStatefulWidget {
  final VoidCallback onSettingsUpdated;

  const NotificationSettingsModal({Key? key, required this.onSettingsUpdated})
    : super(key: key);

  @override
  ConsumerState<NotificationSettingsModal> createState() =>
      _NotificationSettingsModalState();
}

class _NotificationSettingsModalState
    extends ConsumerState<NotificationSettingsModal> {
  bool _emailNotificationsEnabled = true;
  bool _pushNotificationsEnabled = true;
  Map<String, bool> _typeSettings = {};
  bool _isLoading = false;
  bool _hasInitialized = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(notificationSettingsProvider);
    final theme = Theme.of(context);

    // Initialize settings when data is available
    settingsAsync.whenData((settings) {
      if (!_hasInitialized) {
        setState(() {
          _emailNotificationsEnabled = settings.emailNotificationsEnabled;
          _pushNotificationsEnabled = settings.pushNotificationsEnabled;
          _typeSettings = Map.from(settings.typeSettings);
          _hasInitialized = true;
        });
      }
    });

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text('Notification Settings', style: theme.textTheme.titleLarge),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),

              const SizedBox(height: 16),

              // Settings content
              Expanded(
                child: settingsAsync.when(
                  data: (_) => _buildSettingsContent(scrollController),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) =>
                      Center(child: Text('Error loading settings: $error')),
                ),
              ),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveSettings,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.0),
                        )
                      : const Text('SAVE SETTINGS'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsContent(ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      children: [
        // Global notification toggles
        _buildSectionTitle('Delivery Methods'),
        SwitchListTile(
          title: const Text('Email Notifications'),
          value: _emailNotificationsEnabled,
          onChanged: (value) {
            setState(() {
              _emailNotificationsEnabled = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Push Notifications'),
          value: _pushNotificationsEnabled,
          onChanged: (value) {
            setState(() {
              _pushNotificationsEnabled = value;
            });
          },
        ),
        const Divider(),

        // Notification type settings
        _buildSectionTitle('Notification Types'),
        ..._buildNotificationTypeToggles(),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }

  List<Widget> _buildNotificationTypeToggles() {
    final notificationTypes = [
      ('ORDER', 'Order Updates', 'Notifications about your orders'),
      ('TRADE', 'Trade Executions', 'Notifications about executed trades'),
      (
        'ACCOUNT',
        'Account Activity',
        'Account deposits, withdrawals and status changes',
      ),
      ('RISK', 'Risk Alerts', 'Risk warnings and alerts'),
      ('SYSTEM', 'System Messages', 'System maintenance and updates'),
    ];

    return notificationTypes.map((type) {
      final typeKey = type.$1;
      final typeTitle = type.$2;
      final typeDescription = type.$3;

      // Initialize the type if not present
      _typeSettings.putIfAbsent(typeKey, () => true);

      return SwitchListTile(
        title: Text(typeTitle),
        subtitle: Text(typeDescription),
        value: _typeSettings[typeKey] ?? true,
        onChanged: (value) {
          setState(() {
            _typeSettings[typeKey] = value;
          });
        },
      );
    }).toList();
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await NotificationManager.updateNotificationSettings(
        emailNotificationsEnabled: _emailNotificationsEnabled,
        pushNotificationsEnabled: _pushNotificationsEnabled,
        typeSettings: _typeSettings,
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onSettingsUpdated();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save settings: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
