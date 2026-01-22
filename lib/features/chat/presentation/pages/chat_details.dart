import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:foxscope/features/chat/presentation/pages/user_chat.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../notifications/presentation/pages/notification_detials_page.dart' hide EditFieldType;
import '../../../scope/presentation/pages/scopeActions.dart';
import 'forward_page.dart';
import 'package:share_plus/share_plus.dart';

class ChatDetailsPage extends StatefulWidget {
  const ChatDetailsPage({super.key});

  @override
  State<ChatDetailsPage> createState() => _ChatDetailsPageState();
}

class _ChatDetailsPageState extends State<ChatDetailsPage> {
  final Set<int> _selectedMessages = {};
  int? _selectedChatIndex;
  bool get _selectionMode => _selectedMessages.isNotEmpty;
  final Map<String, dynamic> _mockScope = {
    'id': 111,
    'name': '111-111-111.foxScope',
    'img': null,
  };
  void _showDeleteDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          // Ensure the dialog's shape matches the screenshot
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                16), // Slightly larger radius for the screenshot look
          ),
          // Remove default title/content padding for the custom layout
          titlePadding: EdgeInsets.zero,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 24, vertical: 12),

          // --- Custom Header (Icon + Disclaimer) ---
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 24),
              // Orange Information Icon
              const CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary,
                // Sample Orange color
                child: Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              // Bolded "Disclaimer" text
              const Text(
                "Disclaimer",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // --- Full Content Message ---
          content: const Text(
            "Are you sure you want to delete this message?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
              // Match the dark text color
              height: 1.2,
            ),
          ),

          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),

          // --- Buttons (Row with Expanded) ---
          actions: [
            Row(
              children: [
                // 1. Delete Button (Orange, Solid, Wide)
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      // Sample Orange color
                      minimumSize: const Size(double.infinity, 50),
                      // Ensure height
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      // TODO: Add delete account logic here
                      Navigator.pop(context);

                    },
                    child: const Text(
                      "Delete",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),
                // Spacing between buttons

                // 2. Cancel Button (White with Black/Grey Border)
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(
                          double.infinity, 50), // Ensure height
                      side: const BorderSide(
                        color: Colors.grey, // Border color
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.black, // Text color
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (_selectionMode) {
              setState(() => _selectedMessages.clear());
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: _selectionMode
            ? Text(
          "${_selectedMessages.length}",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        )
            : Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UserChatPage(),
                  ),
                );
              },
              child:

              Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundImage: AssetImage('assets/images/mahmoud.png'),
                  ),

                  const SizedBox(width: 10),
                  const Text(
                    "Fayez wa7d bs",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
        actions: _selectionMode
            ? [
          IconButton(
            icon: const Icon(Icons.reply, color:AppColors.primary),
            onPressed: () {
              debugPrint("➡️ Forward ${_selectedMessages.length} messages");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ForwardPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.primary),
            onPressed: () {
              debugPrint("➡️ Share messages");

              Share.share("https://foxscope.com/scope/685-214-751");

            },
          ),

          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.primary),
            onPressed: () {
              _showDeleteDialog();
              setState(() => _selectedMessages.clear());
            },
          ),
        ]
            : [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              _showOptionsDialog();
              },
          ),
        ],
      ),


      body: Column(
        children: [
          const SizedBox(height: 12),

          /// Date chip
          _buildDateChip("05/01/2024"),

          const SizedBox(height: 12),

          /// Incoming message
          _incomingMessage(),

          const SizedBox(height: 16),

          _buildDateChip("Today"),

          const SizedBox(height: 16),

          /// Outgoing message
          _outgoingMessage(),

          const Spacer(),

          /// Send button (static)
          Padding(
            padding: const EdgeInsets.fromLTRB(20,16,20,40),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  "Send",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= UI Components =================
  Widget _buildDateChip(String text) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _incomingMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScopeCard(
            scope: _mockScope,
            loggedName: "Ahmed Mohamed",
            enableNavigation: false, // 👈 optional in chat
          ),

          const SizedBox(height: 6),
          _messageBubble(
            messageId: 1,
            text: "Lorem Ipsum is simply dummy text.",
            isMine: false,
          ),
          const SizedBox(height: 4),
          const Text(
            "✓ 12:34pm",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _outgoingMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ScopeCard(
            scope: _mockScope,
            loggedName: "Ahmed Mohamed",
            enableNavigation: false, // 👈 optional in chat
          ),

          const SizedBox(height: 6),
          _messageBubble(
            messageId: 2,
            text: "Another message here",
            isMine: true,
          ),
          const SizedBox(height: 4),
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, size: 14, color: AppColors.primary),
              SizedBox(width: 4),
              Text(
                "12:34pm",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _messageBubble({
    required int messageId,
    required String text,
    required bool isMine,
  }) {
    final bool isSelected = _selectedMessages.contains(messageId);

    return GestureDetector(
      onLongPress: () {
        setState(() {
          _selectedMessages.add(messageId);
        });
      },
      onTap: () {
        if (_selectionMode) {
          setState(() {
            if (isSelected) {
              _selectedMessages.remove(messageId);
            } else {
              _selectedMessages.add(messageId);
            }
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.orange.withOpacity(0.2) // ✅ selection highlight
              : isMine
              ? Colors.grey.shade300
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  void _showOptionsDialog() {
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
              _option(
                text: 'Add to Favorites',
                onTap: () {
                  Navigator.pop(context);
                  // TODO
                },
              ),
              const Divider(height: 0),

              /// 🔕 MUTE / UNMUTE
              _option(
                text: 'Mute',
                onTap: () {
                  Navigator.pop(context);

                },
              ),

              const Divider(height: 0),

              /// 🚫 BLOCK / UNBLOCK
              _option(
                text:  'Add Nickname',
                onTap: () async{
                  Navigator.pop(context);
                  final result = await showEditFieldDialog(
                    context: context,
                    title: "Edit Nickname",
                    fieldType: EditFieldType.text,
                    initialText: 'Fayez',
                  );
                  if (result is String && result.isNotEmpty) {
                  }
                },
              ),

              const Divider(height: 0),

              /// 🚫 BLOCK / UNBLOCK
              _option(
                text: 'Block',
                onTap: () {
                  Navigator.pop(context);

                },
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _option({
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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

}

// ================= Scope Action Button =================

class ScopeCard extends StatelessWidget {
  final Map<String, dynamic> scope;
  final String loggedName;
  final bool enableNavigation;

  const ScopeCard({
    super.key,
    required this.scope,
    required this.loggedName,
    this.enableNavigation = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: enableNavigation
          ? () {
        final scopeId = scope['id'];
        debugPrint('➡️ Navigating to scopeId: $scopeId');
        context.push('/scope/$scopeId');
      }
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: scope['img'] != null &&
                      scope['img'].toString().isNotEmpty
                      ? Image.network(
                    "http://sit.foxscope.com/imgs/${scope['img']}",
                    height: 55,
                    width: 55,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Image.asset(
                        'assets/images/profile_sample.png',
                        height: 55,
                        width: 55,
                        fit: BoxFit.cover,
                      );
                    },
                  )
                      : Image.asset(
                    'assets/images/user.png',
                    height: 55,
                    width: 55,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            scope['name'] ?? "",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            FontAwesomeIcons.thumbtack,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.only(left: 50),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF000080),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              loggedName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(
                height: 1,
                color: Colors.white,
              ),
            ),
            ScopeActionsRow(scope: scope, card: true),
          ],
        ),
      ),
    );
  }
}
