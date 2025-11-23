import 'package:flutter/material.dart';
import 'package:smart_food_frontend/presentation/screens/client/link_bank_form_screen.dart';

class BankCardList extends StatelessWidget {
  final String name;
  final String logo;

  const BankCardList({
    super.key,
    required this.name,
    required this.logo,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Row(
          children: [
            ClipOval(
              child: Image.asset(
                logo,
                width: 32,
                height: 32,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 12),

            Text(
              name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
