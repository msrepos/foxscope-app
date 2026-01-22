import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_footer.dart';
import '../../../../core/widgets/app_header.dart';
import 'notification_detials_page.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool _isOn = true;
  final List<NotificationItemModel> _items = List.generate(
    3,
        (_) => NotificationItemModel(isMuted: false),
  );


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: "Notifications"),
      backgroundColor: const Color(0xFFF2F2F2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopNotificationBox(),
            Divider(
              height: 30,
              color: Colors.grey,
            ),
            const Text(
              "Contact",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            buildNotificationItem(context, 0),
            const SizedBox(height: 12),
            buildNotificationItem(context, 1),
            const SizedBox(height: 12),
            buildNotificationItem(context, 2),
          ],
        ),
      ),
      bottomNavigationBar: const AppFooter(currentIndex: 3),
    );
  }

  Widget _buildTopNotificationBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active,
              size: 40, color: Colors.black87),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "All Notifications",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4),
                Text(
                  "Allow notifications for all scopes",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
          Switch(
            value: _isOn,
            onChanged: (value) {
              setState(() {
                _isOn = value;
              });
            },
            activeColor: AppColors.primary,
            activeTrackColor: Colors.black12,
          )
        ],
      ),
    );
  }

  Widget buildNotificationItem(
      BuildContext context,
      int index,
      ) {
    final item = _items[index];

    return Slidable(
      key: ValueKey(index),

      // 👉 Swipe LEFT
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.35,
        children: [
          SlidableAction(
            onPressed: (_) {
              setState(() {
                item.isMuted = !item.isMuted;
              });
            },
            backgroundColor:
            item.isMuted ? Colors.green : Colors.red,
            foregroundColor: Colors.white,
            icon: item.isMuted
                ? Icons.notifications_active
                : Icons.notifications_off,
            label: item.isMuted ? 'Unmute' : 'Mute',
          ),
        ],
      ),

      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const NotificationDetails(),
            ),
          );
        },
        child: _notificationCard(item),
      ),
    );
  }

  Widget _notificationCard(NotificationItemModel item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/profile_sample.png',
                  height: 70,
                  width: 70,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Ahmed Mohamed",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF000080),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Ahmed Mohamed",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.bookmark,
                          size: 24, color: AppColors.primary),
                      Icon(Icons.push_pin_outlined,
                          size: 20, color: Colors.black),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          "1",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // 🔔 MUTED / UNMUTED ICON
                      Icon(
                        item.isMuted
                            ? Icons.notifications_off_outlined
                            : Icons.notifications_active_outlined,
                        size: 22,
                        color: item.isMuted
                            ? Colors.grey
                            : Colors.black87,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Divider(height: 1),
          ),

          Row(
            children: const [
              Expanded(
                child: Text(
                  "Updated his Email Address",
                  style: TextStyle(fontSize: 15),
                ),
              ),
              Text(
                "12:34pm",
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

}

class MySwitchExample extends StatefulWidget {
  const MySwitchExample({super.key});

  @override
  State<MySwitchExample> createState() => _MySwitchExampleState();
}

class _MySwitchExampleState extends State<MySwitchExample> {
  bool _isOn = true; // <-- controls the switch

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _isOn,
      onChanged: (bool value) {
        setState(() {
          _isOn = value; // <-- toggles between true / false
        });
      },
      activeColor: Colors.orange,
      activeTrackColor: Colors.orange[300],
    );
  }
}


class NotificationItemModel {
  bool isMuted;

  NotificationItemModel({this.isMuted = false});
}
