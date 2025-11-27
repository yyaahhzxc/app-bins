import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../providers/app_state.dart';
import '../utils/constants.dart';
import '../widgets/pill_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: kTextOnPrimary,
          ),
        ),
        backgroundColor: kPrimaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kPaddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // System Theme Section
            const Text(
              'System Theme',
              style: TextStyle(
                fontSize: kHeadingSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: kPaddingMedium),
            PillCard(
              child: Row(
                children: [
                  _buildThemeButton(
                    context,
                    'Light',
                    Icons.light_mode,
                    !appState.isDarkMode,
                    () => appState.setTheme(false),
                  ),
                  const SizedBox(width: kPaddingSmall),
                  _buildThemeButton(
                    context,
                    'System',
                    Icons.settings_brightness,
                    false,
                    () {
                      // System theme would require platform brightness detection
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('System theme coming soon'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: kPaddingSmall),
                  _buildThemeButton(
                    context,
                    'Dark',
                    Icons.dark_mode,
                    appState.isDarkMode,
                    () => appState.setTheme(true),
                  ),
                ],
              ),
            ),
            const SizedBox(height: kPaddingLarge),

            // Notifications Section (Placeholder)
            const Text(
              'Notifications',
              style: TextStyle(
                fontSize: kHeadingSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: kPaddingMedium),
            _buildNotificationTile(
              context,
              'Time to claim!',
              '12:00 PM',
              true,
            ),
            const SizedBox(height: kPaddingMedium),
            OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Add notification feature coming soon'),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Add Notification'),
            ),
            const SizedBox(height: kPaddingLarge),

            // Data Management Section
            const Text(
              'Data Management',
              style: TextStyle(
                fontSize: kHeadingSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: kPaddingMedium),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _importData(context, appState),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                    child: const Text('Import Data'),
                  ),
                ),
                const SizedBox(width: kPaddingMedium),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _exportData(context, appState),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                    child: const Text('Export Data'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: kPaddingMedium),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _resetData(context, appState),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kErrorColor,
                  minimumSize: const Size(0, 48),
                ),
                child: const Text('Reset Data'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeButton(
    BuildContext context,
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onPressed,
  ) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? kPrimaryColor : Colors.grey[300],
          foregroundColor: isSelected ? kTextOnPrimary : kTextPrimary,
          padding: const EdgeInsets.symmetric(vertical: kPaddingMedium),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: kPaddingSmall / 2),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile(
    BuildContext context,
    String title,
    String time,
    bool isEnabled,
  ) {
    return PillCard(
      child: Row(
        children: [
          const Icon(Icons.notifications, color: kPrimaryColor),
          const SizedBox(width: kPaddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: kBodySize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: kCaptionSize,
                    color: kTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notification toggle coming soon'),
                ),
              );
            },
            activeTrackColor: kPrimaryColor,
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context, AppState appState) async {
    try {
      final jsonData = appState.exportData();
      final fileName = '$kExportFileName${DateTime.now().millisecondsSinceEpoch}$kExportFileExtension';

      await Share.shareXFiles(
        [
          XFile.fromData(
            utf8.encode(jsonData),
            name: fileName,
            mimeType: 'application/json',
          ),
        ],
        subject: "Vince's App - Data Backup",
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data exported successfully'),
            backgroundColor: kPrimaryColor,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: kErrorColor,
          ),
        );
      }
    }
  }

  Future<void> _importData(BuildContext context, AppState appState) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        
        final success = await appState.importData(jsonString);

        if (context.mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Data imported successfully'),
                backgroundColor: kPrimaryColor,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Import failed: Invalid data format'),
                backgroundColor: kErrorColor,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $e'),
            backgroundColor: kErrorColor,
          ),
        );
      }
    }
  }

  Future<void> _resetData(BuildContext context, AppState appState) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadius),
          ),
          title: const Text('Reset Data'),
          content: const Text(
            'Are you sure you want to delete all data? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: kErrorColor),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final success = await appState.resetData();
      
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All data has been reset'),
              backgroundColor: kPrimaryColor,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reset failed'),
              backgroundColor: kErrorColor,
            ),
          );
        }
      }
    }
  }
}
