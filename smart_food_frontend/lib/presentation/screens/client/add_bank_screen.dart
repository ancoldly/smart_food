import 'package:flutter/material.dart';
import 'package:smart_food_frontend/presentation/widgets/item_bank_gird.dart';
import 'package:smart_food_frontend/presentation/widgets/item_bank_list.dart';

class AddBankScreen extends StatelessWidget {
  const AddBankScreen({super.key});

  static const Color backgroundColor = Color(0xFFFFF6EC);
  static const Color primaryGreen = Color(0xFF5B7B56);
  static const Color sectionTitle = Colors.black87;

  final double cardSize = 70;

  static const popularBanks = [
    {"name": "Vietcombank", "logo": "./assets/banks/vietcombank.png"},
    {"name": "VPBank", "logo": "./assets/banks/vpbank.png"},
    {"name": "Techcombank", "logo": "./assets/banks/techcombank.png"},
    {"name": "BIDV", "logo": "./assets/banks/bidv.png"},
    {"name": "Agribank", "logo": "./assets/banks/agribank.png"},
    {"name": "VietinBank", "logo": "./assets/banks/vietinbank.png"},
    {"name": "MBBank", "logo": "./assets/banks/mbbank.png"},
    {"name": "Sacombank", "logo": "./assets/banks/sacombank.png"},
  ];

  static const allBanks = [
    {"name": "Vietcombank", "logo": "./assets/banks/vietcombank.png"},
    {"name": "VPBank", "logo": "./assets/banks/vpbank.png"},
    {"name": "Techcombank", "logo": "./assets/banks/techcombank.png"},
    {"name": "BIDV", "logo": "./assets/banks/bidv.png"},
    {"name": "Agribank", "logo": "./assets/banks/agribank.png"},
    {"name": "VietinBank", "logo": "./assets/banks/vietinbank.png"},
    {"name": "MBBank", "logo": "./assets/banks/mbbank.png"},
    {"name": "Sacombank", "logo": "./assets/banks/sacombank.png"},
    {"name": "ACB", "logo": "./assets/banks/acb.png"},
    {"name": "SHB", "logo": "./assets/banks/shb.png"},
    {"name": "HDBank", "logo": "./assets/banks/hdbank.png"},
    {"name": "TPBank", "logo": "./assets/banks/tpbank.png"},
    {"name": "OCB", "logo": "./assets/banks/ocb.png"},
    {"name": "VIB", "logo": "./assets/banks/vib.png"},
    {"name": "Eximbank", "logo": "./assets/banks/eximbank.png"},
    {"name": "DongA Bank", "logo": "./assets/banks/donga.png"},
    {"name": "SCB", "logo": "./assets/banks/scb.png"},
    {"name": "SeABank", "logo": "./assets/banks/seabank.png"},
    {"name": "MSB", "logo": "./assets/banks/msb.png"},
    {"name": "PVcomBank", "logo": "./assets/banks/pvcombank.png"},
    {"name": "Nam A Bank", "logo": "./assets/banks/namabank.png"},
    {"name": "KienlongBank", "logo": "./assets/banks/kienlongbank.png"},
    {"name": "ABBANK", "logo": "./assets/banks/abbank.png"},
    {"name": "VietCapital Bank", "logo": "./assets/banks/vietcapital.png"},
    {"name": "Bac A Bank", "logo": "./assets/banks/bacabank.png"},
    {"name": "Saigonbank", "logo": "./assets/banks/saigonbank.png"},
    {"name": "VietBank", "logo": "./assets/banks/vietbank.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: primaryGreen),
        ),
        title: const Text(
          "Thêm Ngân hàng liên kết",
          style: TextStyle(
            color: primaryGreen,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "NGÂN HÀNG PHỔ BIẾN",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: sectionTitle,
              ),
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: popularBanks.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                final bank = popularBanks[index];
                return BankGridItem(
                  name: bank["name"]!,
                  logo: bank["logo"]!,
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              "TOÀN BỘ NGÂN HÀNG",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: sectionTitle,
              ),
            ),
            const SizedBox(height: 14),
            Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDF9),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: allBanks.length,
                  separatorBuilder: (_, __) => Container(
                    height: 1,
                    color: Colors.black12.withOpacity(0.07),
                  ),
                  itemBuilder: (context, index) {
                    final bank = allBanks[index];
                    return BankCardList(
                      name: bank["name"]!,
                      logo: bank["logo"]!,
                    );
                  },
                )),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
