// ignore_for_file: use_build_context_synchronously


import 'package:hmwssb_stores/common_imports.dart';
import 'package:hmwssb_stores/src/datamodel/items_by_purchase_order_number.dart';
import 'package:hmwssb_stores/src/features/login/login_index.dart';
import 'package:hmwssb_stores/src/features/supplies/ui/file_tapped_view_screen.dart';
import 'package:hmwssb_stores/src/features/supplies/ui/role_based_submit_screen/admin_submit_screen.dart';
import 'package:hmwssb_stores/src/features/supplies/ui/role_based_submit_screen/qc_dgm_submit_screen.dart';
import 'package:hmwssb_stores/src/features/supplies/ui/role_based_submit_screen/qc_gm_submit_screen.dart';
import 'package:hmwssb_stores/src/features/supplies/ui/role_based_submit_screen/qc_manager_submit_screen.dart';
import 'package:hmwssb_stores/src/features/supplies/ui/role_based_submit_screen/store_dgm_submit_screen.dart';
import 'package:hmwssb_stores/src/features/supplies/ui/role_based_submit_screen/store_gm_submit_screen.dart';
import 'package:hmwssb_stores/src/features/supplies/ui/role_based_submit_screen/store_manager_submit_screen.dart';
import 'package:hmwssb_stores/src/features/supplies/ui/roles_based_screen/admin_screen.dart';
import 'package:hmwssb_stores/src/features/supplies/ui/roles_based_screen/store_gm_screen.dart';
import 'package:hmwssb_stores/src/features/supplies/ui/roles_based_screen/store_manager_screen.dart';
import 'package:hmwssb_stores/src/features/supplies/ui/roles_based_screen/store_dgm_screen.dart';
import 'package:hmwssb_stores/src/features/supplies/ui/roles_based_screen/qc_manager_screen.dart';
import 'package:hmwssb_stores/src/features/supplies/ui/roles_based_screen/qc_gm_screen.dart';
import 'package:hmwssb_stores/src/features/supplies/ui/roles_based_screen/qc_dgm_screen.dart';
import 'package:hmwssb_stores/src/features/supplies/ui/supply_dashboard_screen.dart';

class NavigateRoutes {
  /// Define a global key for the navigator
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Define all the routes here
  static void toRoleScreen(String roleCode) {
    if (LocalStorages.getIsLoggedIn() == true) {
      // final String roleCode = LocalStorages.getRole();
      printDebug("role name $roleCode");


      switch (roleCode) {
        case 'TP':
          toSupplyDashboardScreen();
          break;
        case 'ADMIN':
          toAdminScreen();
          break;
        case 'STMGR':
          toStoreManagerScreen();
          break;
        case 'STGM':
          toStoreGmScreen();
          break;
        case 'STCGM':
          toStoreGmScreen();
          break;
        case 'STDGM':
          toStoreDGMScreen();
          break;
        case 'QCMGR':
          toQCManagerScreen();
          break;
        case 'QCGM': printDebug("object it went inside this $roleCode");
          toQCGMScreen();
          break;
        case 'QCCGM': printDebug("object it went inside this $roleCode");
        toQCGMScreen();
        break;
        case 'QCDGM':
          toQCDGMScreen();
          break;
        default:
          EasyLoading.showError("No valid role assigned to your account.");
          navigateToLoginScreen(); // fallback
          break;
      }
    } else {
      navigateToLoginScreen();
    }
  }

  static Future<void> toRoleSubmitScreen(String roleCode, ItemsByPurchaseOrderModel data) async {
    switch (roleCode) {
      case 'TP':
        await navigatePush(widget: FileViewTappedScreen(data: data));
        break;
      case 'ADMIN':
        await navigatePush(widget: AdminSubmitScreen(data: data));
        break;
      case 'STMGR':
        await navigatePush(widget: StoreManagerSubmitScreen(data: data));
        break;
      case 'STGM':
        await navigatePush(widget: StoreGmSubmitScreen(data: data));
        break;
      case 'STDGM':
        await navigatePush(widget: StoreDgmSubmitScreen(data: data));
        break;
      case 'QCMGR':
        await navigatePush(widget: QcManagerSubmitScreen(data: data));
        break;
      case 'QCGM':
        await navigatePush(widget: QcGmSubmitScreen(data: data));
        break;
      case 'QCDGM':
        await navigatePush(widget: QcDgmSubmitScreen(data: data));
        break;
      default:
        EasyLoading.showError("No submission screen defined for this role: $roleCode");
    }
  }

  /// Role-based navigation methods
  static void toSupplyDashboardScreen() {
    _replaceScreen(const SupplyDashboardScreen());
  }

  static void toAdminScreen() {
    _replaceScreen(const AdminScreen());
  }

  static void toStoreManagerScreen() {
    _replaceScreen(const StoreManagerScreen());
  }

  static void toStoreGmScreen() {
    _replaceScreen(const StoreGmScreen());
  }

  static void toStoreDGMScreen() {
    _replaceScreen(const StoreDgmScreen());
  }

  static void toQCManagerScreen() {
    _replaceScreen(const StoreQcManagerScreen());
  }

  static void toQCGMScreen() {
    _replaceScreen(const StoreQcGmManagerScreen());
  }

  static void toQCDGMScreen() {
    _replaceScreen(const StoreQcDgmManagerScreen());
  }


  ///Defined only login screen route
  static dynamic navigateToLoginScreen({bool isLogoutTap = false}) async {
    if (isLogoutTap) {
      await LocalStorages.logOutUser();
      return Navigator.pushAndRemoveUntil(
          navigatorKey.currentContext!,
          MaterialPageRoute<Widget>(builder: (_) =>  LoginScreenWidget()),
              (Route<dynamic> route) => false);
    }
    return Timer(
        const Duration(seconds: 5),
            () => Navigator.pushAndRemoveUntil(
            navigatorKey.currentContext!,
            MaterialPageRoute<Widget>(
                builder: (_) =>  LoginScreenWidget()),
                (Route<dynamic> route) => false));
  }

  static dynamic navigateToOTPScreen() {
    // return Navigator.pushReplacement(
    //     navigatorKey.currentContext!,
    //     MaterialPageRoute<Widget>(
    //         builder: (_) => const OTPVerificationScreen()));
  }

  static Future<Widget?> navigatePush(
      {required Widget widget, BuildContext? context}) {
    return Navigator.push(context ?? navigatorKey.currentContext!,
        MaterialPageRoute<Widget>(builder: (_) => widget));
  }

  static void navigatePop({BuildContext? context}) {
    return Navigator.pop(context ?? navigatorKey.currentContext!);
  }
  static void _replaceScreen(Widget screen) {
    if (navigatorKey.currentContext != null) {
      Navigator.pushAndRemoveUntil(
        navigatorKey.currentContext!,
        MaterialPageRoute<Widget>(builder: (_) => screen),
            (Route<dynamic> route) => false,
      );
    } else {
      debugPrint("Navigator context is null");
    }
  }
}
