import 'package:flutter/material.dart';

class StyledAlertDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget> actions;

  const StyledAlertDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      content: content,
      actions: actions,
      elevation: 8,
      backgroundColor: Colors.white,
      shadowColor: Colors.black.withOpacity(0.2),
    );
  }
}