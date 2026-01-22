import 'dart:io';

import 'package:flutter/material.dart';
import 'package:foxscope/core/theme/app_colors.dart';
import 'package:foxscope/features/home/presentation/pages/qr_code_page.dart';
import '../../../../core/widgets/app_footer.dart';
import '../../../../core/widgets/app_header.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

class NotificationDetails extends StatefulWidget {
  const NotificationDetails({super.key});

  @override
  State<NotificationDetails> createState() => _NotificationDetailsState();
}

class _NotificationDetailsState extends State<NotificationDetails> {
  String _hintName = "Ahmed Mohamed";
  String _scopeType = "Government Office";
  File? _profileImage;
  bool _hasImage = true;
  final ImagePicker _picker = ImagePicker();
  final notifications = [
    NotificationItem(
      action: 'Updated',
      subject: 'Phone Number',
      dateTime: '04/30/2025 2:57 PM',
    ),
    NotificationItem(
      action: 'Updated',
      subject: 'Phone Number',
      dateTime: '04/30/2025 2:57 PM',
    ),
    NotificationItem(
      action: 'Updated',
      subject: 'Phone Number',
      dateTime: '04/30/2025 2:57 PM',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: "Scopes"),
      backgroundColor: const Color(0xFFF2F2F2),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildScopeCard(context),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppFooter(currentIndex: 0),
    );
  }

  Widget _buildScopeCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () async {
                    _showPhotoOptionsDialog();
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/profile_sample.png',
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Ahmed Mohamed",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final result = await showEditFieldDialog(
                            context: context,
                            title: "Edit Hint Name",
                            fieldType: EditFieldType.text,
                            initialText: _hintName,
                          );

                          if (result is String && result.isNotEmpty) {
                            setState(() => _hintName = result);
                          }
                        },
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF000080),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: Text(
                              _hintName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.bookmark,
                  color: AppColors.primary,
                ),
                const Icon(
                  Icons.more_vert,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            indent: 15,
            endIndent: 15,
          ),

          const SizedBox(height: 12),

          // Action icons row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _actionIcon(Icons.map_outlined, "Go", onTap: () {}),
                _actionIcon(Icons.arrow_forward, "Forward", onTap: () {}),
                _shareIconBox("https://foxscope.com/scope/685-214-751"),
                _actionIcon(Icons.qr_code_2, "QR", onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const QrCodePage(),
                    ),
                  );
                }),
                _actionIcon(Icons.copy, "Copy", onTap: () {}),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Divider(
            height: 1,
            indent: 15,
            endIndent: 15,
          ),

          // Government office pill
          const SizedBox(height: 20),
          InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () async {
              final result = await showEditFieldDialog(
                context: context,
                title: "Select Scope Category",
                fieldType: EditFieldType.dropdown,
                options: const [
                  "Restaurant",
                  "Coffee Shop",
                  "Government Office",
                  "Clinic",
                  "Store",
                ],
                initialDropdownValue: _scopeType,
              );

              if (result is String && result.isNotEmpty) {
                setState(() {
                  _scopeType = result;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E9DD),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                _scopeType,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Divider(
            height: 1,
            indent: 15,
            endIndent: 15,
          ),

          // Location / Views / Saved
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _InfoColumn(
                  icon: Icons.location_on_outlined,
                  label: "Location",
                  value: "Qatar",
                ),
                _DashedDivider(),
                _InfoColumn(
                  icon: Icons.remove_red_eye_outlined,
                  label: "Views",
                  value: "1M",
                ),
                _DashedDivider(),
                _InfoColumn(
                  icon: Icons.save_outlined,
                  label: "Saved",
                  value: "2",
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Divider(
            height: 1,
            indent: 15,
            endIndent: 15,
          ),

          NotificationsSection(items: notifications),
        ],
      ),
    );
  }

  Widget _actionIcon(IconData icon, String label,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary, width: 1.3),
            ),
            child: Icon(
              icon,
              size: 24,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _shareIconBox(String shareText) {
    return InkWell(
        onTap: () {
          // This opens the native share sheet (WhatsApp, Bluetooth, etc.)
          Share.share(shareText);
        },
        borderRadius: BorderRadius.circular(10),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: const Icon(
                Icons.share_outlined,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Share",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ],
        ));
  }

  //region Image=====================================
  void _showPhotoOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _photoOption(
                icon: Icons.photo_camera_outlined,
                text: 'Change Scope Photo',
                onTap: () {
                  Navigator.of(context).pop();
                  _changePhoto();
                },
              ),
              const Divider(height: 0),
              _photoOption(
                icon: Icons.remove_red_eye_outlined,
                text: 'Preview Scope Photo',
                onTap: () {
                  Navigator.of(context).pop();
                  _previewPhoto();
                },
              ),
              const Divider(height: 0),
              _photoOption(
                icon: Icons.delete_outline,
                text: 'Delete Scope Photo',
                onTap: () {
                  Navigator.of(context).pop();
                  _deletePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _changePhoto() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading:
                    const Icon(Icons.photo_camera, color: AppColors.primary),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.grey),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
          _hasImage = true;
        });

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile photo updated successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _previewPhoto() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.all(24), // margin from screen edges
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                backgroundColor: Colors.black,
                elevation: 0,
                automaticallyImplyLeading: false,
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text(
                  'Scope Photo',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 260,
                  height: 260, // whatever size you like
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(130),
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 3.0,
                      child: _profileImage != null
                          ? Image.file(
                              _profileImage!,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'assets/images/profile_sample.png',
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _deletePhoto() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Delete Photo'),
          content: const Text(
            'Are you sure you want to delete your scope photo?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _profileImage = null;
                  _hasImage = false;
                });
                Navigator.pop(context);

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Scope photo deleted'),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _photoOption({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
//endregion
}

class _InfoColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoColumn({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 22, color: Colors.grey[700]),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Colors.grey,
            width: 0.5,
            style: BorderStyle.solid,
          ),
        ),
      ),
    );
  }
}

Future<dynamic> showEditFieldDialog({
  required BuildContext context,
  required String title,
  required EditFieldType fieldType,
  String? initialText,
  List<String>? options,
  String? initialDropdownValue,
  List<String>? initialSelectedValues,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return _EditFieldDialog(
        title: title,
        fieldType: fieldType,
        initialText: initialText,
        options: options,
        initialDropdownValue: initialDropdownValue,
        initialSelectedValues: initialSelectedValues,
      );
    },
  );
}

//=============================================================

enum EditFieldType {
  text,
  dropdown,
  multiSelect,
}

class _EditFieldDialog extends StatefulWidget {
  final String title;
  final EditFieldType fieldType;
  final String? initialText;
  final List<String>? options;
  final String? initialDropdownValue;
  final List<String>? initialSelectedValues;

  const _EditFieldDialog({
    super.key,
    required this.title,
    required this.fieldType,
    this.initialText,
    this.options,
    this.initialDropdownValue,
    this.initialSelectedValues,
  });

  @override
  State<_EditFieldDialog> createState() => _EditFieldDialogState();
}

class _EditFieldDialogState extends State<_EditFieldDialog> {
  late TextEditingController _textController;
  String? _selectedDropdown;
  late Set<String> _selectedMulti;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText ?? "");
    _selectedDropdown = widget.initialDropdownValue;
    _selectedMulti = {...?widget.initialSelectedValues};
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),

            // Body based on type
            _buildField(),

            const SizedBox(height: 20),

            // Buttons
            Row(
              children: [
                // Save
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      dynamic result;

                      switch (widget.fieldType) {
                        case EditFieldType.text:
                          result = _textController.text;
                          break;
                        case EditFieldType.dropdown:
                          result = _selectedDropdown;
                          break;
                        case EditFieldType.multiSelect:
                          result = _selectedMulti.toList();
                          break;
                      }

                      Navigator.pop(context, result);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Save",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Cancel
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, null),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Colors.black87),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField() {
    switch (widget.fieldType) {
      case EditFieldType.text:
        return TextField(
          controller: _textController,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        );

      case EditFieldType.dropdown:
        final items = widget.options ?? [];
        return DropdownButtonFormField<String>(
          value: _selectedDropdown ?? (items.isNotEmpty ? items.first : null),
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  ))
              .toList(),
          onChanged: (val) {
            setState(() {
              _selectedDropdown = val;
            });
          },
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        );

      case EditFieldType.multiSelect:
        final options = widget.options ?? [];
        return SizedBox(
          height: 200, // in case there are many options
          child: ListView(
            children: options.map((opt) {
              final selected = _selectedMulti.contains(opt);
              return CheckboxListTile(
                value: selected,
                title: Text(opt),
                dense: true,
                onChanged: (v) {
                  setState(() {
                    if (v == true) {
                      _selectedMulti.add(opt);
                    } else {
                      _selectedMulti.remove(opt);
                    }
                  });
                },
              );
            }).toList(),
          ),
        );
    }
  }
}

//=============================================================

class NotificationItem {
  final String action; // e.g. "Updated"
  final String subject; // e.g. "Phone Number"
  final String dateTime; // e.g. "04/30/2025 2:57 PM"

  NotificationItem({
    required this.action,
    required this.subject,
    required this.dateTime,
  });
}

class NotificationsSection extends StatefulWidget {
  final List<NotificationItem> items;

  const NotificationsSection({
    super.key,
    required this.items,
  });

  @override
  State<NotificationsSection> createState() => _NotificationsSectionState();
}

class _NotificationsSectionState extends State<NotificationsSection> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // HEADER
        GestureDetector(
          onTap: () {
            setState(() => _isExpanded = !_isExpanded);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                /*BoxShadow(
                  color: Colors.black,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),*/
              ],
            ),
            child: Row(
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 26,
                  color: Colors.black87,
                ),
              ],
            ),
          ),
        ),

        // CONTENT
        if (_isExpanded) const SizedBox(height: 8),
        if (_isExpanded)
          Container(
            color: Colors.transparent,
            child: Column(
              children: List.generate(widget.items.length, (index) {
                final item = widget.items[index];
                return Column(
                  children: [
                    _buildNotificationRow(item),
                    if (index != widget.items.length - 1)
                      const Divider(
                        height: 24,
                        thickness: 0.8,
                        color: Color(0xFFE5E5E5),
                      ),
                  ],
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildNotificationRow(NotificationItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${item.action} ',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                TextSpan(
                  text: item.subject,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.dateTime,
            style: const TextStyle(
              color: Colors.black45,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
