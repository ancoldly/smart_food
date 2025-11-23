import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_food_frontend/providers/payment_provider.dart';
import 'package:smart_food_frontend/presentation/widgets/bank_card.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<PaymentProvider>(context, listen: false).loadPayments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final payments = paymentProvider.payments;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF6EC),
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Color(0xFF5B7B56)),
        ),
        title: const Text(
          "Thanh toán",
          style: TextStyle(
            color: Color(0xFF5B7B56),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Cách thức thanh toán đơn giản, tiết\nkiệm nhất.",
              style: TextStyle(
                fontSize: 16,
                height: 1.4,
                color: Color(0xFF5B3A1E),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              "Ngân hàng liên kết",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: Center(
                child: paymentProvider.loading
                    ? const CircularProgressIndicator(color: Color(0xFF5B7B56))

                    : payments.isEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "./assets/images/no_payment.png", 
                                width: 180,
                                height: 180,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "Chưa có tài khoản nào,\nbạn hãy thêm tài khoản mới.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF5B3A1E),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            itemCount: payments.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final payment = payments[index];

                              return BankCard(
                                payment: payment,
                              );
                            },
                          ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.addBank);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B7B56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "Thêm tài khoản",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
