import 'package:flutter/material.dart';

class HomeCategoryToggle extends StatelessWidget {
  const HomeCategoryToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: Image.asset(
                "assets/images/ic_eat.png",
                height: 25,
              ),
              label: const Text("Ăn uống",
                  style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 0,
                side: const BorderSide(
                    color: Color.fromARGB(255, 195, 195, 195)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: Image.asset(
                "assets/images/ic_grocery.png",
                height: 25,
              ),
              label: const Text("Thực phẩm",
                  style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 0,
                side: const BorderSide(
                    color: Color.fromARGB(255, 195, 195, 195)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
