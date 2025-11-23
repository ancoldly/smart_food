import 'package:flutter/material.dart';
import 'package:smart_food_frontend/data/models/address_model.dart';
import 'package:smart_food_frontend/presentation/screens/client/edit_address_screen.dart';

class AddressItem extends StatelessWidget {
  final AddressModel address;

  const AddressItem({
    super.key,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE9D0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFC27A),
          width: 1,
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    address.label,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF5B3A1E),
                    ),
                  ),

                  if (address.isDefault) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC5C0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "Mặc định",
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFCA5244),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditAddressScreen(address: address),
                    ),
                  );
                },
                child: const Text(
                  "Chỉnh sửa",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5B7B56),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            address.addressLine,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF6B6B6B),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Text(
                address.receiverName,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Color(0xFF4A4A4A),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                address.receiverPhone,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF4A4A4A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
