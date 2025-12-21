import 'package:flutter/material.dart';
import 'package:smart_food_frontend/data/models/address_model.dart';
import 'package:smart_food_frontend/data/models/user_model.dart';

class HomeHeader extends StatelessWidget {
  final UserModel? user;
  final List<AddressModel> addresses;
  final AddressModel? defaultAddress;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchSubmitted;
  final VoidCallback? onSearchTap;

  const HomeHeader({
    super.key,
    required this.user,
    required this.addresses,
    required this.defaultAddress,
    this.searchController,
    this.onSearchSubmitted,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasAddress = addresses.isNotEmpty;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white,
                backgroundImage: (user?.avatar != null &&
                        (user?.avatar?.isNotEmpty ?? false))
                    ? NetworkImage(user!.avatar!)
                    : null,
                child: (user?.avatar == null || (user?.avatar?.isEmpty ?? true))
                    ? const Icon(Icons.person,
                        color: Color(0xFFFF7043), size: 28)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.fullName ?? user?.username ?? "Người dùng",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      defaultAddress?.addressLine ??
                          (hasAddress
                              ? addresses.first.addressLine
                              : "Chưa có địa chỉ"),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onSearchTap ??
                      () => onSearchSubmitted
                          ?.call(searchController?.text.trim() ?? ""),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            controller: searchController,
                            decoration: const InputDecoration(
                              hintText: "Hôm nay bạn muốn ăn, uống gì nào?",
                              border: InputBorder.none,
                            ),
                            onTap: onSearchTap,
                            onSubmitted: (_) => onSearchTap?.call(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.mic, color: Color(0xFFFF7043)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
