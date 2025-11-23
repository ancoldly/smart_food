import 'package:flutter/material.dart';
import 'package:smart_food_frontend/presentation/screens/client/link_bank_form_screen.dart';

class BankGridItem extends StatelessWidget {
  final String name;
  final String logo;

  const BankGridItem({
    super.key,
    required this.name,
    required this.logo,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LinkBankFormScreen(
              bankName: name,
              bankLogo: logo,
            ),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle, 
              border: Border.all(color: Colors.black12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: ClipOval(               
                child: Image.asset(
                  logo,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
