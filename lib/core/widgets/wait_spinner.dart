import 'package:flutter/material.dart';
import 'package:foxscope/core/theme/app_colors.dart';

class WaitSpinner extends StatelessWidget {
  static int _shownTime = 0;

  static void show(BuildContext context, {String? msg}) {
    if (_shownTime > 0) return;

    _shownTime = DateTime.now().millisecondsSinceEpoch;

    showDialog(
      context: context,
      builder: (context) => WaitSpinner(msg: msg),
    ).then((_) {
      _shownTime = 0;
    });
  }

  static Future<void> dismiss(BuildContext context) async {
    if (_shownTime > 0) {
      var d = DateTime.now().millisecondsSinceEpoch - _shownTime;
      if (d >= 1000) {
        Navigator.pop(context);
      } else {
        await Future.delayed(
          Duration(milliseconds: 1100 - d),
          () => Navigator.pop(context),
        );
      }
    }
  }

  final String? msg;

  const WaitSpinner({this.msg, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: SizedBox()),
        Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                padding: EdgeInsets.all(15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),

                    //
                    Text(
                      msg ?? "Please wait...",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(child: SizedBox()),
      ],
    );
  }
}
