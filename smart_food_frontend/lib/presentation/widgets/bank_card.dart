import 'package:flutter/material.dart';
import 'package:smart_food_frontend/data/models/payment_model.dart';
import 'package:smart_food_frontend/presentation/screens/client/card_info_screen.dart';

class BankCard extends StatelessWidget {
  final PaymentModel payment;
  final VoidCallback? onTap;

  const BankCard({
    super.key,
    required this.payment, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: payment.isDefault ? const Color(0xFF5B7B56) : Colors.transparent,
          width: payment.isDefault ? 2 : 0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CardInfoScreen(payment: payment),
                    ),
                  );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Image.network(payment.bankLogo, width: 32, height: 32),
              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  payment.bankName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFFFB347)),
            ],
          ),
        ),
      ),
    );
  }
}
