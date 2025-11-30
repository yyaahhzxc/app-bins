import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../providers/app_state.dart';
import '../utils/constants.dart';
import '../models/notification_model.dart';
import '../widgets/custom_text_field.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kPaddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: kPaddingLarge),

              // Theme
              Text(
                'System Theme',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
              ),
              const SizedBox(height: kPaddingMedium),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    _buildThemeSegment(context, 'Light', 0, appState.themeMode),
                    Container(width: 1, height: 40, color: isDark ? Colors.grey[700] : Colors.grey[300]),
                    _buildThemeSegment(context, 'System', 1, appState.themeMode),
                    Container(width: 1, height: 40, color: isDark ? Colors.grey[700] : Colors.grey[300]),
                    _buildThemeSegment(context, 'Dark', 2, appState.themeMode),
                  ],
                ),
              ),
              const SizedBox(height: kPaddingLarge),

              // Notifications
              Text(
                'Notifications',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
              ),
              const SizedBox(height: kPaddingMedium),
              
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: appState.notifications.length,
                separatorBuilder: (ctx, index) => const SizedBox(height: 12),
                itemBuilder: (ctx, index) {
                  return _buildNotificationTile(context, appState, appState.notifications[index]);
                },
              ),
              const SizedBox(height: kPaddingMedium),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showNotificationModal(context, null),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Add Notification', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: kPaddingLarge),

              // Data
              Text(
                'Data Management',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
              ),
              const SizedBox(height: kPaddingMedium),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _importData(context, appState),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        side: BorderSide(color: primaryColor),
                      ),
                      child: Text('Import Data', style: TextStyle(color: primaryColor)),
                    ),
                  ),
                  const SizedBox(width: kPaddingMedium),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _exportData(context, appState),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('Export Data', style: TextStyle(color: Colors.white)),
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
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Reset Data', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSegment(BuildContext context, String label, int mode, int currentMode) {
    final isSelected = mode == currentMode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return Expanded(
      child: InkWell(
        onTap: () {
          context.read<AppState>().setThemeMode(mode);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.horizontal(
              left: mode == 0 ? const Radius.circular(30) : Radius.zero,
              right: mode == 2 ? const Radius.circular(30) : Radius.zero,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSelected) const Icon(Icons.check, size: 16, color: Colors.white),
              if (isSelected) const SizedBox(width: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationTile(BuildContext context, AppState appState, NotificationModel notification) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return InkWell(
      onTap: () => _showNotificationModal(context, notification),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? kSurfaceColorDark : Colors.white,
          border: Border.all(color: isDark ? Colors.grey[800]! : const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            // REVERTED: withValues -> withOpacity
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.access_time_filled, color: primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              notification.time,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? kTextPrimaryDark : kTextPrimary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                notification.description,
                style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Switch(
              value: notification.isActive,
              onChanged: (val) {
                appState.updateNotification(notification.copyWith(isActive: val));
              },
              // REVERTED: activeThumbColor -> activeColor
              activeColor: Colors.white,
              activeTrackColor: primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationModal(BuildContext context, NotificationModel? notification) {
    final isEditing = notification != null;
    final timeController = TextEditingController(text: notification?.time ?? '12:00 PM');
    final descController = TextEditingController(text: notification?.description ?? '');
    bool isActive = notification?.isActive ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            final primaryColor = Theme.of(context).colorScheme.primary;
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return Padding(
              padding: EdgeInsets.only(
                left: kPaddingLarge,
                right: kPaddingLarge,
                top: kPaddingMedium,
                bottom: MediaQuery.of(context).viewInsets.bottom + kPaddingLarge,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isEditing ? 'Edit Notification' : 'Add Notification',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Time',
                          controller: timeController,
                          prefixIcon: Icon(Icons.access_time_filled, color: primaryColor),
                          readOnly: true,
                          onTap: () async {
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (picked != null) {
                              setState(() {
                                timeController.text = picked.format(context);
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        children: [
                          Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
                          Switch(
                            value: isActive,
                            onChanged: (val) => setState(() => isActive = val),
                            // REVERTED: activeThumbColor -> activeColor
                            activeColor: Colors.white,
                            activeTrackColor: primaryColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'Notification',
                    controller: descController,
                    hintText: 'Enter description',
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      if (isEditing) ...[
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await context.read<AppState>().deleteNotification(notification.id!);
                              if (context.mounted) Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kErrorColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            child: const Text('Delete', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            side: BorderSide(color: isDark ? Colors.grey[600]! : Colors.grey),
                          ),
                          child: Text('Cancel', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (timeController.text.isEmpty || descController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a description'),
                                  backgroundColor: kErrorColor,
                                ),
                              );
                              return;
                            }

                            final appState = context.read<AppState>();
                            
                            if (isEditing) {
                              await appState.updateNotification(notification.copyWith(
                                time: timeController.text,
                                description: descController.text,
                                isActive: isActive,
                              ));
                            } else {
                              await appState.addNotification(NotificationModel(
                                time: timeController.text,
                                description: descController.text,
                                isActive: isActive,
                              ));
                            }
                            
                            if (context.mounted) Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text('Confirm', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _exportData(BuildContext context, AppState appState) async {
    final jsonData = appState.exportData();
    final fileName = 'vince_app_backup_${DateTime.now().millisecondsSinceEpoch}.json';
    await Share.shareXFiles(
      [XFile.fromData(utf8.encode(jsonData), name: fileName, mimeType: 'application/json')],
      subject: "Vince's App Data",
    );
    if (context.mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data exported successfully'), backgroundColor: kPrimaryColor),
      );
    }
  }

  Future<void> _importData(BuildContext context, AppState appState) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final success = await appState.importData(jsonString);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Data imported successfully' : 'Failed to import data'),
            backgroundColor: success ? kPrimaryColor : kErrorColor,
          ),
        );
      }
    }
  }

  Future<void> _resetData(BuildContext context, AppState appState) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? kSurfaceColorDark : Colors.white,
        title: Text('Reset Data', style: TextStyle(color: isDark ? kTextPrimaryDark : kTextPrimary)),
        content: Text('Are you sure you want to delete all data? This cannot be undone.', style: TextStyle(color: isDark ? kTextPrimaryDark : kTextPrimary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await appState.resetData();
              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data reset'), backgroundColor: kPrimaryColor),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: kErrorColor)),
          ),
        ],
      ),
    );
  }
}