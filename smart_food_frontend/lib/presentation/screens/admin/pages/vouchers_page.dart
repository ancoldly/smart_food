import 'package:flutter/material.dart';

class VouchersPage extends StatefulWidget {
  const VouchersPage({super.key});

  @override
  State<VouchersPage> createState() => _VouchersPageState();
}

class _VouchersPageState extends State<VouchersPage> {
  final TextEditingController codeCtrl = TextEditingController();
  final TextEditingController discountCtrl = TextEditingController();
  final TextEditingController minOrderCtrl = TextEditingController();

  String discountType = "percent";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Voucher Manager"),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreateVoucherSheet(context),
        child: const Icon(Icons.add),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _voucherCard("SALE20", "20%", "100,000đ", "Percent"),
          _voucherCard("FOOD50", "50,000đ", "200,000đ", "Amount"),
        ],
      ),
    );
  }

  Widget _voucherCard(String code, String discount, String minOrder, String type) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),

        title: Text(
          code,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text("Discount: $discount"),
            Text("Min Order: $minOrder"),

            const SizedBox(height: 8),

            Chip(
              label: Text(type),
              backgroundColor: type == "Percent"
                  ? Colors.blue.withOpacity(0.15)
                  : Colors.green.withOpacity(0.15),
              labelStyle: TextStyle(
                color: type == "Percent" ? Colors.blue : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  //=============================
  //       CREATE FORM SHEET
  //=============================

  void _openCreateVoucherSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              const Text(
                "Create Voucher",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),
              _inputField("Voucher Code", codeCtrl),

              const SizedBox(height: 12),
              _inputField("Discount", discountCtrl),

              const SizedBox(height: 12),
              _inputField("Minimum Order", minOrderCtrl),

              const SizedBox(height: 20),

              Row(
                children: [
                  Radio(
                    value: "percent",
                    groupValue: discountType,
                    onChanged: (value) {
                      setState(() => discountType = value.toString());
                    },
                  ),
                  const Text("Percent (%)"),

                  const SizedBox(width: 20),

                  Radio(
                    value: "amount",
                    groupValue: discountType,
                    onChanged: (value) {
                      setState(() => discountType = value.toString());
                    },
                  ),
                  const Text("Amount (VND)"),
                ],
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Voucher created!")),
                    );
                  },
                  child: const Text("Create"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _inputField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
