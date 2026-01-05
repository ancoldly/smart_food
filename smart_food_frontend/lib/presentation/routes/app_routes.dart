import 'package:flutter/material.dart';

// admin
import 'package:smart_food_frontend/presentation/screens/admin/dashboard_page.dart';
import 'package:smart_food_frontend/presentation/screens/admin/merchants_all_page.dart';
import 'package:smart_food_frontend/presentation/screens/admin/merchants_pending_page.dart';
import 'package:smart_food_frontend/presentation/screens/admin/shippers_all_page.dart';
import 'package:smart_food_frontend/presentation/screens/admin/shippers_pending_page.dart';
import 'package:smart_food_frontend/presentation/screens/admin/users_page.dart';
import 'package:smart_food_frontend/presentation/screens/admin/vouchers_page.dart';

// client
import 'package:smart_food_frontend/presentation/screens/client/add_address_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/add_bank_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/address_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/category_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/contact_support_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/error_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/help_center_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/home_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/login_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/main_bottom_nav.dart';
import 'package:smart_food_frontend/presentation/screens/client/payment_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/profile_detail_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/profile_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/register_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/select_location_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/splash_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/store_by_category_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/store_search_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/store_suggestions_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/store_nearby_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/store_detail_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/store_info_detail_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/search_input_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/voucher_wallet_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/voucher_detail_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/product_detail_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/store_reviews_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/store_voucher_detail_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/checkout_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/order_tracking_screen.dart';

// merchant
import 'package:smart_food_frontend/presentation/screens/merchant/add_category_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/add_edit_option_group_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/add_edit_option_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/add_edit_template_group_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/add_edit_template_option_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/add_employee_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/add_product_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/category_detail_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/edit_category_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/edit_employee_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/edit_product_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/edit_store_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/employee_detail_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/employee_manage_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/main_bottom_nav_merchant.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/merchant_pending_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/merchant_start_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/menu_category_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/store_operating_hours_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/on_step_one_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/on_step_zero_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/option_group_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/option_list_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/store_voucher_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/product_manage_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/product_template_link_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/store_info_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/store_campaign_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/settlement_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/withdraw_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/template_group_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/template_option_list_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/terms_business_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/terms_personal_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/store_tags_screen.dart';
import 'package:smart_food_frontend/presentation/screens/shipper/shipper_register_screen.dart';
import 'package:smart_food_frontend/presentation/screens/shipper/shipper_pending_screen.dart';
import 'package:smart_food_frontend/presentation/screens/shipper/shipper_home_screen.dart';
import 'package:smart_food_frontend/presentation/screens/shipper/shipper_wallet_screen.dart';
import 'package:smart_food_frontend/presentation/screens/shipper/shipper_topup_screen.dart';
import 'package:smart_food_frontend/presentation/screens/shipper/shipper_withdraw_screen.dart';
import 'package:smart_food_frontend/presentation/screens/shipper/shipper_earnings_screen.dart';
import 'package:smart_food_frontend/presentation/screens/shipper/shipper_leaderboard_screen.dart';
import 'package:smart_food_frontend/presentation/screens/shipper/shipper_support_screen.dart';
import 'package:smart_food_frontend/presentation/screens/shipper/shipper_profile_edit_screen.dart';
import 'package:smart_food_frontend/presentation/screens/shipper/shipper_notifications_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/notifications_screen.dart' as MerchantNotif;
import 'package:smart_food_frontend/presentation/screens/client/notifications_screen.dart'
    as ClientNotif;
import 'package:smart_food_frontend/presentation/screens/shipper/shipper_history_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/merchant_topup_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/merchant_withdraw_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/merchant_finance_screen.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/merchant_reviews_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/order_detail_screen.dart';
import 'package:smart_food_frontend/presentation/screens/client/review_order_screen.dart';

class AppRoutes {
  static const String splash = "/splash";
  static const String login = "/login";
  static const String register = "/register";
  static const String main = "/main";
  static const String home = "/home";
  static const String selectLocation = "/select_location";
  static const String contactSupport = "/contact_support";
  static const String profile = "/profile";
  static const String profileDetail = "/profile_detail";
  static const String address = "/address";
  static const String addAddress = "/add_address";
  static const String payment = "/payment";
  static const String addBank = "/add_bank";
  static const String category = "/category";
  static const String helpCenter = "/help_center";
  static const String storeByCategory = "/store_by_category";
  static const String searchStore = "/search_store";
  static const String searchInput = "/search_input";
  static const String storeSuggestions = "/store_suggestions";
  static const String storeNearby = "/store_nearby";
  static const String storeDetail = "/store_detail";
  static const String storeInfoDetail = "/store_info_detail";
  static const String productDetail = "/product_detail";
  static const String checkout = "/checkout";
  static const String storeReviews = "/store_reviews";
  static const String orderTracking = "/order_tracking";

  static const String onStepZero = "/on_step_zero";
  static const String onStepOne = "/on_step_one";
  static const String onStepTwo = "/on_step_two";
  static const String merchantPending = "/merchant_pending";
  static const String merchantStart = "/merchant_start";
  static const String mainMerchant = "/main_merchant";
  static const String storeInfo = "/store_info";
  static const String storeOperatingHours = "/store_operating_hours";
  static const String storeCampaigns = "/store_campaigns";
  static const String storeVouchers = "/store_vouchers";
  static const String settlement = "/settlement";
  static const String merchantFinance = "/merchant_finance";
  static const String merchantReviews = "/merchant_reviews";
  static const String reviewOrder = "/review_order";
  static const String withdraw = "/withdraw";
  static const String editStore = "/edit_store";
  static const String employeeManage = "/employee_manage";
  static const String addEmployee = "/add_employee";
  static const String detailEmployee = "/detail_employee";
  static const String editEmployee = "/edit_employee";
  static const String termsPersonal = "/terms_personnal";
  static const String termsBusiness = "/terms_business";
  static const String menuCategory = "/menu_category";
  static const String detailCategory = "/detailCategory";
  static const String addCategory = "/add_category";
  static const String editCategory = "/edit_category";
  static const String productManage = "/product_manage";
  static const String addProduct = "/add_product";
  static const String editProduct = "/edit_product";
  static const String optionGroups = "/option_groups";
  static const String addOptionGroup = "/add_option_group";
  static const String editOptionGroup = "/edit_option_group";
  static const String optionList = "/option_list";
  static const String addOption = "/add_option";
  static const String editOption = "/edit_option";
  static const String templateGroups = "/template_groups";
  static const String addTemplateGroup = "/add_template_group";
  static const String editTemplateGroup = "/edit_template_group";
  static const String templateOptionList = "/template_option_list";
  static const String addTemplateOption = "/add_template_option";
  static const String editTemplateOption = "/edit_template_option";
  static const String productTemplateLink = "/product_template_link";
  static const String storeTags = "/store_tags";

  static const String adminDashboard = "/admin_dashboard";
  static const String usersPage = "/admin_users_page";
  static const String merchantsAll = "/admin_merchants_all";
  static const String merchantsPending = "/admin_merchants_pending";
  static const String shippersAll = "/admin_shippers_all";
  static const String shippersPending = "/admin_shippers_pending";
  static const String vouchersPage = "/admin_vouchers_page";
  static const String voucherWallet = "/voucher_wallet";
  static const String voucherDetail = "/voucher_detail";
  static const String storeVoucherDetail = "/store_voucher_detail";
  static const String shipperRegister = "/shipper_register";
  static const String shipperPending = "/shipper_pending";
  static const String shipperHome = "/shipper_home";
  static const String shipperWallet = "/shipper_wallet";
  static const String shipperTopup = "/shipper_topup";
  static const String shipperWithdraw = "/shipper_withdraw";
  static const String shipperEarnings = "/shipper_earnings";
  static const String shipperLeaderboard = "/shipper_leaderboard";
  static const String shipperSupport = "/shipper_support";
  static const String shipperProfileEdit = "/shipper_profile_edit";
  static const String shipperHistory = "/shipper_history";
  static const String shipperNotifications = "/shipper_notifications";
  static const String merchantTopup = "/merchant_topup";
  static const String merchantWithdraw = "/merchant_withdraw";
  static const String orderDetail = "/order_detail";
  static const String userNotifications = "/notifications";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case main:
        final int index = settings.arguments as int? ?? 0;
        return MaterialPageRoute(
          builder: (_) => MainBottomNav(initialIndex: index),
        );
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case profileDetail:
        return MaterialPageRoute(builder: (_) => const ProfileDetailScreen());
      case address:
        return MaterialPageRoute(builder: (_) => const AddressScreen());
      case addAddress:
        return MaterialPageRoute(builder: (_) => const AddAddressScreen());
      case selectLocation:
        return MaterialPageRoute(builder: (_) => const SelectLocationScreen());
      case contactSupport:
        return MaterialPageRoute(builder: (_) => const ContactSupportScreen());
      case payment:
        return MaterialPageRoute(builder: (_) => const PaymentScreen());
      case addBank:
        return MaterialPageRoute(builder: (_) => const AddBankScreen());
      case category:
        return MaterialPageRoute(builder: (_) => const CategoryScreen());
      case storeByCategory:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final name = args["name"] as String? ?? "Danh mục";
        return MaterialPageRoute(
            builder: (_) => StoreByCategoryScreen(categoryName: name));
      case searchInput:
        return MaterialPageRoute(builder: (_) => const SearchInputScreen());
      case searchStore:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final keyword = args["keyword"] as String? ?? "";
        return MaterialPageRoute(
            builder: (_) => StoreSearchScreen(keyword: keyword));
      case storeSuggestions:
        return MaterialPageRoute(
          builder: (_) => const StoreSuggestionsScreen(),
        );
      case storeNearby:
        return MaterialPageRoute(
          builder: (_) => const StoreNearbyScreen(),
        );
      case storeDetail:
        return MaterialPageRoute(
          builder: (_) => StoreDetailScreen(
            store: settings.arguments as dynamic,
          ),
        );
      case storeInfoDetail:
        final argsInfo = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => StoreInfoDetailScreen(
            store: argsInfo["store"] as dynamic,
            distanceText: argsInfo["distanceText"] as String?,
            etaText: argsInfo["etaText"] as String?,
          ),
        );
      case storeReviews:
        final argsReview = settings.arguments as Map<String, dynamic>? ?? {};
        final storeId =
            argsReview["storeId"] as int? ?? argsReview["store_id"] as int? ?? 0;
        final storeName =
            argsReview["storeName"] as String? ?? argsReview["store_name"] as String? ?? "";
        return MaterialPageRoute(
          builder: (_) => StoreReviewsScreen(
            storeId: storeId,
            storeName: storeName.isNotEmpty ? storeName : "Cửa hàng",
          ),
        );
      case productDetail:
        return MaterialPageRoute(
          builder: (_) => ProductDetailScreen(
            product: settings.arguments as dynamic,
          ),
        );
      case checkout:
        return MaterialPageRoute(
          builder: (_) => CheckoutScreen(
            store: settings.arguments as dynamic,
          ),
        );
      case helpCenter:
        return MaterialPageRoute(builder: (_) => const HelpCenterScreen());

      // merchant
      case onStepZero:
        return MaterialPageRoute(builder: (_) => const OnStepZeroScreen());
      case onStepOne:
        return MaterialPageRoute(builder: (_) => const OnStepOneScreen());
      case merchantPending:
        return MaterialPageRoute(builder: (_) => const MerchantPendingScreen());
      case merchantStart:
        return MaterialPageRoute(builder: (_) => const MerchantStartScreen());
      case mainMerchant:
        return MaterialPageRoute(builder: (_) => const MainBottomNavMerchant());
      case storeInfo:
        return MaterialPageRoute(builder: (_) => const StoreInfoScreen());
      case storeOperatingHours:
        return MaterialPageRoute(
          builder: (_) => const StoreOperatingHoursScreen(),
        );
      case storeCampaigns:
        return MaterialPageRoute(
          builder: (_) => const StoreCampaignScreen(),
        );
      case storeVouchers:
        return MaterialPageRoute(
          builder: (_) => const StoreVoucherScreen(),
        );
      case settlement:
        return MaterialPageRoute(
          builder: (_) => const SettlementScreen(),
        );
      case merchantFinance:
        return MaterialPageRoute(
          builder: (_) => const MerchantFinanceScreen(),
        );
      case merchantReviews:
        return MaterialPageRoute(
          builder: (_) => const MerchantReviewsScreen(),
        );
      case withdraw:
        return MaterialPageRoute(
          builder: (_) => const WithdrawScreen(),
        );
      case termsPersonal:
        return MaterialPageRoute(builder: (_) => const TermsPersonalScreen());
      case termsBusiness:
        return MaterialPageRoute(builder: (_) => const TermsBusinessScreen());
      case menuCategory:
        return MaterialPageRoute(builder: (_) => const MenuCategoryScreen());
      case detailCategory:
        return MaterialPageRoute(
          builder: (_) =>
              CategoryDetailScreen(categoryId: settings.arguments as int),
        );
      case addCategory:
        return MaterialPageRoute(builder: (_) => const AddCategoryScreen());
      case editCategory:
        return MaterialPageRoute(
          builder: (_) => EditCategoryScreen(
            category: settings.arguments as dynamic,
          ),
        );
      case productManage:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ProductManageScreen(
            categoryId: args?["categoryId"] as int?,
            categoryName: args?["categoryName"] as String?,
          ),
        );
      case addProduct:
        return MaterialPageRoute(
          builder: (_) => AddProductScreen(
            categoryId: settings.arguments as int?,
          ),
        );
      case editProduct:
        return MaterialPageRoute(
          builder: (_) => EditProductScreen(
            product: settings.arguments as dynamic,
          ),
        );
      case optionGroups:
        return MaterialPageRoute(
          builder: (_) => OptionGroupScreen(
            product: settings.arguments as dynamic,
          ),
        );
      case addOptionGroup:
        final product = settings.arguments as dynamic;
        return MaterialPageRoute(
          builder: (_) => AddEditOptionGroupScreen(product: product),
        );
      case editOptionGroup:
        final argsEditGroup = settings.arguments as dynamic;
        return MaterialPageRoute(
          builder: (_) => AddEditOptionGroupScreen(
            product: argsEditGroup is Map ? argsEditGroup["product"] : null,
            group:
                argsEditGroup is Map ? argsEditGroup["group"] : argsEditGroup,
          ),
        );
      case optionList:
        return MaterialPageRoute(
          builder: (_) => OptionListScreen(
            group: settings.arguments as dynamic,
          ),
        );
      case addOption:
        final group = settings.arguments as dynamic;
        return MaterialPageRoute(
          builder: (_) => AddEditOptionScreen(group: group),
        );
      case editOption:
        final arg = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => AddEditOptionScreen(
            group: arg["group"],
            option: arg["option"],
          ),
        );

      // templates
      case templateGroups:
        return MaterialPageRoute(builder: (_) => const TemplateGroupScreen());
      case addTemplateGroup:
        return MaterialPageRoute(
          builder: (_) => const AddEditTemplateGroupScreen(),
        );
      case editTemplateGroup:
        return MaterialPageRoute(
          builder: (_) => AddEditTemplateGroupScreen(
            group: settings.arguments as dynamic,
          ),
        );
      case templateOptionList:
        return MaterialPageRoute(
          builder: (_) => TemplateOptionListScreen(
            group: settings.arguments as dynamic,
          ),
        );
      case addTemplateOption:
        final groupTemp = settings.arguments as dynamic;
        return MaterialPageRoute(
          builder: (_) => AddEditTemplateOptionScreen(group: groupTemp),
        );
      case editTemplateOption:
        final argTemp = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => AddEditTemplateOptionScreen(
            group: argTemp["group"],
            option: argTemp["option"],
          ),
        );
      case productTemplateLink:
        return MaterialPageRoute(
          builder: (_) => ProductTemplateLinkScreen(
            product: settings.arguments as dynamic,
          ),
        );
      case storeTags:
        return MaterialPageRoute(builder: (_) => const StoreTagsScreen());

      case editStore:
        return MaterialPageRoute(
            builder: (_) =>
                EditStoreScreen(storeId: settings.arguments as int));
      case employeeManage:
        return MaterialPageRoute(
            builder: (_) => const EmployeeManagementScreen());
      case addEmployee:
        return MaterialPageRoute(builder: (_) => const AddEmployeeScreen());
      case detailEmployee:
        return MaterialPageRoute(
            builder: (_) =>
                EmployeeDetailScreen(employeeId: settings.arguments as int));
      case editEmployee:
        return MaterialPageRoute(
            builder: (_) =>
                EditEmployeeScreen(employeeId: settings.arguments as int));

      // admin
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const DashboardPage());
      case usersPage:
        return MaterialPageRoute(builder: (_) => const UsersPage());
      case merchantsAll:
        return MaterialPageRoute(builder: (_) => const MerchantsAllPage());
      case shippersAll:
        return MaterialPageRoute(builder: (_) => const ShippersAllPage());
      case merchantsPending:
        return MaterialPageRoute(builder: (_) => const MerchantsPendingPage());
      case shippersPending:
        return MaterialPageRoute(builder: (_) => const ShippersPendingPage());
      case vouchersPage:
        return MaterialPageRoute(builder: (_) => const VouchersPage());
      case voucherWallet:
        return MaterialPageRoute(builder: (_) => const VoucherWalletScreen());
      case voucherDetail:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final voucher = args["voucher"];
        return MaterialPageRoute(
            builder: (_) =>
                VoucherDetailScreen(voucher: voucher as dynamic));
      case storeVoucherDetail:
        return MaterialPageRoute(
          builder: (_) => StoreVoucherDetailScreen(
            voucher: settings.arguments as dynamic,
          ),
        );
      case shipperRegister:
        return MaterialPageRoute(
          builder: (_) => const ShipperRegisterScreen(),
        );
      case shipperPending:
        return MaterialPageRoute(
          builder: (_) => const ShipperPendingScreen(),
        );
      case shipperHome:
        return MaterialPageRoute(
          builder: (_) => const ShipperHomeScreen(),
        );
      case shipperWallet:
        return MaterialPageRoute(
          builder: (_) => const ShipperWalletScreen(),
        );
      case shipperTopup:
        return MaterialPageRoute(
          builder: (_) => const ShipperTopupScreen(),
        );
      case shipperWithdraw:
        return MaterialPageRoute(
          builder: (_) => const ShipperWithdrawScreen(),
        );
      case shipperEarnings:
        return MaterialPageRoute(
          builder: (_) => const ShipperEarningsScreen(),
        );
      case shipperLeaderboard:
        return MaterialPageRoute(
          builder: (_) => const ShipperLeaderboardScreen(),
        );
      case shipperSupport:
        return MaterialPageRoute(
          builder: (_) => const ShipperSupportScreen(),
        );
      case shipperProfileEdit:
        return MaterialPageRoute(
          builder: (_) => const ShipperProfileEditScreen(),
        );
      case shipperNotifications:
        return MaterialPageRoute(
          builder: (_) => const ShipperNotificationsScreen(),
        );
      case userNotifications:
        return MaterialPageRoute(
          builder: (_) => const ClientNotif.ClientNotificationsScreen(),
        );
      case shipperHistory:
        return MaterialPageRoute(
          builder: (_) => const ShipperHistoryScreen(),
        );
      case merchantTopup:
        return MaterialPageRoute(
          builder: (_) => const MerchantTopupScreen(),
        );
      case merchantWithdraw:
        return MaterialPageRoute(
          builder: (_) => const MerchantWithdrawScreen(),
        );
      case orderDetail:
        return MaterialPageRoute(
          builder: (_) => OrderDetailScreen(order: settings.arguments as dynamic),
        );
      case orderTracking:
        return MaterialPageRoute(
          builder: (_) => OrderTrackingScreen(order: settings.arguments as dynamic),
        );
      case reviewOrder:
        return MaterialPageRoute(
          builder: (_) => ReviewOrderScreen(order: settings.arguments as dynamic),
        );

      default:
        return MaterialPageRoute(builder: (_) => const ErrorScreen());
    }
  }
}
