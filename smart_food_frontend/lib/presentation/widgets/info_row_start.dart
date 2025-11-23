import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  final Color iconBackground;
  final Color iconBorder;
  final IconData icon;
  final String title;
  final String description;

  const InfoRow({super.key, 
    required this.iconBackground,
    required this.iconBorder,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: iconBorder, width: 1.2),
          ),
          child: Icon(
            icon,
            size: 26,
            color: iconBorder,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3A2D1C),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: Color(0xFF6B5A4B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}