import 'package:flutter/material.dart';

class MenuItemWidget extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const MenuItemWidget({
    super.key,
    required this.label,
    required this.icon,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 20),
        child: Row(
          children: [
            Icon(
              icon,
              size: 30,
              color: iconColor ?? Colors.black87,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 30,
              color: Colors.black38,
            ),
          ],
        ),
      ),
    );
  }
}
