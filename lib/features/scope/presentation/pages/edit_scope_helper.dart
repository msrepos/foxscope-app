import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:foxscope/features/scope/presentation/pages/scopeActions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:foxscope/core/theme/app_colors.dart';
import 'package:foxscope/features/scope/presentation/pages/create_page.dart';
import 'package:foxscope/features/scope/presentation/pages/scope_page.dart' hide EditFieldType;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_env.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/widgets/map.dart';
import '../../../market/presentation/pages/edit_marketplace.dart';
import 'add_to_group.dart';
import 'map_page.dart';

class SelectFieldSheet extends StatefulWidget {
  const SelectFieldSheet({super.key});

  @override
  State<SelectFieldSheet> createState() => _SelectFieldSheetState();
}

class _SelectFieldSheetState extends State<SelectFieldSheet> {
  String expandedSection = "contact";
  String _phoneNumber = "00 000 00000";
  String _countryCode = "+976";
  String _address = "";
  String _website = "";
  String _email = "";
  String _description = "";
  String _facebook = "";
  String _tiktok = "";
  String _instagram = "";
  String _whatsapp = "";
  String _workingHours = "";
  String _menu = "";
  String _complains = "";
  String _promotions = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              "Select Field",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _section(
              title: "Contact Information",
              expanded: expandedSection == "contact",
              onTap: () => setState(() => expandedSection = "contact"),
              children: [
                _item(Icons.location_on, "Address", () async {
                  final result = await showEditFieldDialog(
                    context: context,
                    title: "Edit Address",
                    fieldType: EditFieldType.text, // ✅ CORRECT
                    initialText: _address,
                  );

                  if (result is String) {
                    setState(() => _address = result);
                  }
                }),
                _item(Icons.edit, "Description", () async {
                  final result = await showEditFieldDialog(
                    context: context,
                    title: "Edit Description",
                    fieldType: EditFieldType.text,
                    initialText: _description,
                  );

                  if (result is String) {
                    setState(() => _description = result);
                  }
                }),
                _item(Icons.public, "Website", () async {
                  final result = await showEditFieldDialog(
                    context: context,
                    title: "Edit Website",
                    fieldType: EditFieldType.text,
                    initialText: _website,
                  );

                  if (result is String) {
                    setState(() => _website = result);
                  }
                }),
                _item(Icons.access_time, "Working Hours", () {
                  showWorkingHoursDialog(context);
                }),
                _item(Icons.smartphone, "Mobile", () async {
                  final result = await showEditFieldDialog(
                    context: context,
                    title: "Edit Phone Number",
                    fieldType: EditFieldType.phone, // ✅ ONLY HERE
                    initialText: _phoneNumber,
                  );

                  if (result is Map) {
                    setState(() {
                      _countryCode = result["countryCode"];
                      _phoneNumber = result["number"];
                    });
                  }
                }),
                _item(Icons.call, "Phone", () async {
                  final result = await showEditFieldDialog(
                    context: context,
                    title: "Edit Phone Number",
                    fieldType: EditFieldType.phone, // ✅ ONLY HERE
                    initialText: _phoneNumber,
                  );

                  if (result is Map) {
                    setState(() {
                      _countryCode = result["countryCode"];
                      _phoneNumber = result["number"];
                    });
                  }
                }),
                _item(Icons.email, "Email", () async {
                  final result = await showEditFieldDialog(
                    context: context,
                    title: "Edit Email",
                    fieldType: EditFieldType.text,
                    initialText: _email,
                  );

                  if (result is String) {
                    setState(() => _email = result);
                  }
                }),
              ],
            ),
            _section(
              title: "Social Media",
              expanded: expandedSection == "social",
              onTap: () => setState(() => expandedSection = "social"),
              children: [
                _item(Icons.facebook, "Facebook", () async {
                  final result = await showEditFieldDialog(
                    context: context,
                    title: "Edit Facebook",
                    fieldType: EditFieldType.text,
                    initialText: _facebook,
                  );

                  if (result is String) {
                    setState(() => _facebook = result);
                  }
                }),
                _item(Icons.camera_alt, "Instagram", () async {
                  final result = await showEditFieldDialog(
                    context: context,
                    title: "Edit Instagram",
                    fieldType: EditFieldType.text,
                    initialText: _instagram,
                  );

                  if (result is String) {
                    setState(() => _instagram = result);
                  }
                }),
                _item(Icons.music_note, "Tiktok", () async {
                  final result = await showEditFieldDialog(
                    context: context,
                    title: "Edit Tiktok",
                    fieldType: EditFieldType.text,
                    initialText: _tiktok,
                  );

                  if (result is String) {
                    setState(() => _tiktok = result);
                  }
                }),
                _item(Icons.chat, "Whatsapp", () async {
                  final result = await showEditFieldDialog(
                    context: context,
                    title: "Edit Whatsapp",
                    fieldType: EditFieldType.text,
                    initialText: _whatsapp,
                  );

                  if (result is String) {
                    setState(() => _whatsapp = result);
                  }
                }),
              ],
            ),
            _section(
              title: "Business Information",
              expanded: expandedSection == "business",
              onTap: () => setState(() => expandedSection = "business"),
              children: [
                _item(Icons.access_time, "Working Hours", () async {
                  final result = await showEditFieldDialog(
                    context: context,
                    title: "Edit Working Hours",
                    fieldType: EditFieldType.text,
                    initialText: _workingHours,
                  );

                  if (result is String) {
                    setState(() => _workingHours = result);
                  }
                }),
                _item(Icons.menu_book, "Menu", () async {
                  final result = await showEditFieldDialog(
                    context: context,
                    title: "Edit Menu",
                    fieldType: EditFieldType.text,
                    initialText: _menu,
                  );

                  if (result is String) {
                    setState(() => _menu = result);
                  }
                }),
                _item(Icons.report_problem, "Complains", () async {
                  final result = await showEditFieldDialog(
                    context: context,
                    title: "Edit Complains",
                    fieldType: EditFieldType.text,
                    initialText: _complains,
                  );

                  if (result is String) {
                    setState(() => _complains = result);
                  }
                }),
                _item(Icons.campaign, "Promotions", () async {
                  final result = await showEditFieldDialog(
                    context: context,
                    title: "Edit Promotions",
                    fieldType: EditFieldType.text,
                    initialText: _promotions,
                  );

                  if (result is String) {
                    setState(() => _promotions = result);
                  }
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _section({
  required String title,
  required bool expanded,
  required VoidCallback onTap,
  required List<Widget> children,
}) {
  return Column(
    children: [
      InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Text(title, style: const TextStyle(fontSize: 16)),
              const Spacer(),
              Icon(expanded ? Icons.expand_less : Icons.expand_more),
            ],
          ),
        ),
      ),
      if (expanded)
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(children: children),
        ),
      const SizedBox(height: 12),
    ],
  );
}

Widget _item(IconData icon, String text, VoidCallback onTap) {
  return ListTile(
    onTap: onTap,
    leading: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    ),
    title: Text(text),
  );
}

void showPhoneDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Phone Number",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "00 000 00000",
                prefixText: "+974 ",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text("Save"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

void showWorkingHoursDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return const WorkingHoursDialog();
    },
  );
}

class WorkingHoursDialog extends StatefulWidget {
  const WorkingHoursDialog({super.key});

  @override
  State<WorkingHoursDialog> createState() => _WorkingHoursDialogState();
}

class _WorkingHoursDialogState extends State<WorkingHoursDialog> {
  final List<_WorkingHourRow> rows = [_WorkingHourRow()];

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
            // TITLE (same style)
            Row(
              children: [
                const Text(
                  "Working Hours",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add, color: AppColors.primary),
                  onPressed: () {
                    setState(() {
                      rows.add(_WorkingHourRow());
                    });
                  },
                )
              ],
            ),

            // BODY
            _buildWorkingHours(),

            const SizedBox(height: 20),

            // BUTTONS (same as EditFieldDialog)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO collect working hours
                      Navigator.pop(context, rows);
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

  Widget _buildWorkingHours() {
    return Column(
      children: [
        SizedBox(
          height: 260,
          child: ListView.builder(
            itemCount: rows.length,
            itemBuilder: (context, index) {
              return _workingHourItem(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _workingHourItem(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  dropdownColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: "Select Day",
                    isDense: true,
                    // 👈 reduces height
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                  items: const [
                    "Sunday",
                    "Monday",
                    "Tuesday",
                    "Wednesday",
                    "Thursday",
                    "Friday",
                    "Saturday",
                  ]
                      .map(
                        (d) => DropdownMenuItem(
                      value: d,
                      child: Text(
                        d,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  )
                      .toList(),
                  onChanged: (_) {},
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: AppColors.primary),
                onPressed: () {
                  setState(() {
                    rows.removeAt(index);
                  });
                },
              )
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  dropdownColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: "From",
                    isDense: true,
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                  items: _timeItems(),
                  onChanged: (_) {},
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  dropdownColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: "To",
                    isDense: true,
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                  items: _timeItems(),
                  onChanged: (_) {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _timeItems() {
    return List.generate(
      24,
          (i) {
        final time = "${i.toString().padLeft(2, '0')}:00";
        return DropdownMenuItem(value: time, child: Text(time));
      },
    );
  }
}

class _WorkingHourRow {}


class InfoColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoColumn({
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

class DashedDivider extends StatelessWidget {
  const DashedDivider();

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

class BottomIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const BottomIcon({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 22, color: AppColors.primary),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
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
      return EditFieldDialog(
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



enum PrivacyOption { everyone, contacts, nobody }

class PrivacyDialog extends StatefulWidget {
  const PrivacyDialog({super.key});

  @override
  State<PrivacyDialog> createState() => _PrivacyDialogState();
}

class _PrivacyDialogState extends State<PrivacyDialog> {
  PrivacyOption mapPrivacy = PrivacyOption.everyone;
  PrivacyOption navigationPrivacy = PrivacyOption.everyone;
  PrivacyOption notificationPrivacy = PrivacyOption.contacts;

  Widget _sectionTitle(String title) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _sectionSubtitle(String subtitle) {
    return Center(
      child: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _radioTile(
      String label,
      IconData icon,
      PrivacyOption value,
      PrivacyOption groupValue,
      ValueChanged<PrivacyOption?> onChanged,
      ) {
    return RadioListTile<PrivacyOption>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: AppColors.primary,

      dense: true,
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
      contentPadding: EdgeInsets.zero,
      //horizontalTitleGap: 0,
      //minLeadingWidth: 0,
      controlAffinity: ListTileControlAffinity.leading,

      title: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 6), // minimal icon-text spacing
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Map Privacy
              _sectionTitle("Map Privacy"),
              _sectionSubtitle("Your visibility on the discover map"),
              _radioTile(
                "Everyone",
                Icons.group,
                PrivacyOption.everyone,
                mapPrivacy,
                    (v) => setState(() => mapPrivacy = v!),
              ),
              _radioTile(
                "My Contacts",
                Icons.person_add_alt_1_rounded,
                PrivacyOption.contacts,
                mapPrivacy,
                    (v) => setState(() => mapPrivacy = v!),
              ),
              _radioTile(
                "Nobody",
                Icons.group_remove_sharp,
                PrivacyOption.nobody,
                mapPrivacy,
                    (v) => setState(() => mapPrivacy = v!),
              ),

              /// Navigation Privacy
              _sectionTitle("Navigation Privacy"),
              _sectionSubtitle("Who can navigate location"),
              _radioTile(
                "Everyone",
                Icons.group,
                PrivacyOption.everyone,
                navigationPrivacy,
                    (v) => setState(() => navigationPrivacy = v!),
              ),
              _radioTile(
                "My Contacts",
                Icons.person_add_alt_1_rounded,
                PrivacyOption.contacts,
                navigationPrivacy,
                    (v) => setState(() => navigationPrivacy = v!),
              ),
              _radioTile(
                "Nobody",
                Icons.group_remove_sharp,
                PrivacyOption.nobody,
                navigationPrivacy,
                    (v) => setState(() => navigationPrivacy = v!),
              ),

              /// Notifications Privacy
              _sectionTitle("Notifications Privacy"),
              _sectionSubtitle("Who can see your updates"),
              _radioTile(
                "Everyone",
                Icons.group,
                PrivacyOption.everyone,
                notificationPrivacy,
                    (v) => setState(() => notificationPrivacy = v!),
              ),
              _radioTile(
                "My Contacts",
                Icons.person_add_alt_1_rounded,
                PrivacyOption.contacts,
                notificationPrivacy,
                    (v) => setState(() => notificationPrivacy = v!),
              ),
              _radioTile(
                "Nobody",
                Icons.group_remove_sharp,
                PrivacyOption.nobody,
                notificationPrivacy,
                    (v) => setState(() => notificationPrivacy = v!),
              ),

              /// Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        // ↓ from 14
                        minimumSize: const Size(0, 36), // forces compact height
                      ),
                      onPressed: () {
                        Navigator.pop(context, {
                          "map": mapPrivacy,
                          "navigation": navigationPrivacy,
                          "notifications": notificationPrivacy,
                        });
                      },
                      child: const Text(
                        "Save",
                        style: TextStyle(
                          fontSize: 14, // ↓ from 16
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10), // slightly tighter gap
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: const BorderSide(color: Colors.black),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        minimumSize: const Size(0, 36),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


//======


