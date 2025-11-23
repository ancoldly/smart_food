import 'package:flutter/material.dart';
import 'package:smart_food_frontend/presentation/widgets/common_faq_list.dart';
import 'package:smart_food_frontend/presentation/widgets/service_faq_list.dart';
import 'package:smart_food_frontend/presentation/widgets/tab_chip.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  int _selectedTab = 0; 

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFFFF6EC); 
    const chipSelected = Color(0xFFFED17A); 
    const chipUnselected = Color(0xFFF7E3C8); 
    const titleBrown = Color(0xFF4E3B31); 

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF6EC),
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Color(0xFF5B7B56)),
        ),
        title: const Text(
          "Trung tâm trợ giúp",
          style: TextStyle(
            color: Color(0xFF5B7B56),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              const Text(
                'Trung tâm Thông tin & Câu hỏi thường gặp',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20), 
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: const Row(
                  children: [
                    Icon(Icons.search, size: 20, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      'Tìm kiếm',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  TabChip(
                    label: 'Theo dịch vụ',
                    isSelected: _selectedTab == 0,
                    selectedColor: chipSelected,
                    unselectedColor: chipUnselected,
                    onTap: () => setState(() => _selectedTab = 0),
                  ),
                  const SizedBox(width: 8),
                  TabChip(
                    label: 'Vấn đề chung',
                    isSelected: _selectedTab == 1,
                    selectedColor: chipSelected,
                    unselectedColor: chipUnselected,
                    onTap: () => setState(() => _selectedTab = 1),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Text(
                _selectedTab == 0 ? 'Theo dịch vụ' : 'Vấn đề chung',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: titleBrown,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: SingleChildScrollView(
                  child: _selectedTab == 0
                      ? const ServiceFaqList()
                      : const CommonFaqList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
