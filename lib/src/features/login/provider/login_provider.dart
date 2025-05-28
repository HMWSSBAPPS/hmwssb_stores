import 'dart:io';

import 'package:hmwssb_stores/src/datamodel/userRole_model.dart';

import '../../../../common_imports.dart';
import '../../../core/network/network_index.dart';
import '../../../datamodel/login_model.dart';
import '../../supplies/ui/roles_based_screen/store_manager_screen.dart';
import '../../supplies/ui/supply_dashboard_screen.dart';


class LoginProvider extends ChangeNotifier {
  double appVersion = 0.0;
  bool isLoading = false;

  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final TextEditingController mobileNoController = TextEditingController();
  final FocusNode mobileNoFocusNode = FocusNode();
  final TextEditingController otpController = TextEditingController();
  final FocusNode otpFocusNode = FocusNode();

  final TextEditingController currentPasswordController = TextEditingController();
  final FocusNode currentPasswordFocusNode = FocusNode();
  final TextEditingController newPasswordController = TextEditingController();
  final FocusNode newPasswordFocusNode = FocusNode();
  final TextEditingController confirmPasswordController = TextEditingController();
  final FocusNode confirmPasswordFocusNode = FocusNode();

  MItem2? loggedInUserData;
  bool isUserExist = false;
  String getApiOtp = Constants.empty;
  int timer = 30;

  UserRoleModel? selectedUserRole;
  List<UserRoleModel> userRoleList = <UserRoleModel>[];

  // Track disposal
  bool _isDisposed = false;

  @override
  void dispose() {
    mobileNoController.dispose();
    mobileNoFocusNode.dispose();
    otpController.dispose();
    otpFocusNode.dispose();

    currentPasswordController.dispose();
    currentPasswordFocusNode.dispose();
    newPasswordController.dispose();
    newPasswordFocusNode.dispose();
    confirmPasswordController.dispose();
    confirmPasswordFocusNode.dispose();

    _isDisposed = true;
    super.dispose();
  }

  void safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  void notifyToAllValues() => safeNotifyListeners();

  void setAppVersion(double version) {
    appVersion = version;
    safeNotifyListeners();
  }

  void isLoadData(bool loading) {
    isLoading = loading;
    // Intentionally not calling notifyListeners immediately
  }

  void startTimer() {
    timer = 30;
    const Duration oneSec = Duration(seconds: 1);
    Timer.periodic(oneSec, (Timer t) {
      if (timer < 1) {
        t.cancel();
      } else {
        timer--;
        safeNotifyListeners();
      }
    });
  }

  void clearChangePassWordValues() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  Future<void> verifyOtpAndLogin() async {
    if (otpController.text.trim().isEmpty) {
      EasyLoading.showError("Please enter the OTP");
      return;
    }

    if (otpController.text.trim() != getApiOtp) {
      EasyLoading.showError("Invalid OTP");
      return;
    }

    if (loggedInUserData != null) {
      await handleRoleAndNavigate(loggedInUserData!);
    } else {
      EasyLoading.showError("User data not found");
    }
  }

  Future<void> getOtpApiCall() async {
    isUserExist = false;
    getApiOtp = Constants.empty;
    mobileNoFocusNode.unfocus();
    await Utils.fetchDeviceInfo();
    final Map<String, String> deviceInfo = Utils.deviceInfo;

    // Match keys from your fetchDeviceInfo()
    String deviceID = deviceInfo["deviceID"] ?? "";
    String deviceName = deviceInfo["device"] ?? ""; // 'device' contains model name
    String osVersion = deviceInfo["osVersion"] ?? "";
    String appName = 'STORESAPP';
    String appVersionString = appVersion.toString();

    print("Device Info Sent:\n"
        "deviceID: $deviceID\n"
        "deviceName: $deviceName\n"
        "osVersion: $osVersion");

    final HTTPResponse<dynamic> response = await ApiCalling.callApi(
      apiUrl: AppUrls.getLoginOTPExternalUrl,
      apiFunType: APITypes.post,
      sendingData: <String?, dynamic>{
        'mobileNo': mobileNoController.text.trim(),
        'appName': appName,
        'deviceID': deviceID,
        'appVersion': appVersionString,
        'deviceName': deviceName,
        'osVersion': osVersion,
      },
    );

    if (response.statusCode == 200) {
      final responseBody = response.body is Map<String, dynamic>
          ? response.body
          : jsonDecode(response.body);

      LoginUserModel loginUserModel = LoginUserModel.fromJson(responseBody);

      getApiOtp = loginUserModel.mItem2?.oTP ?? Constants.empty;
      Object userId = loginUserModel.mItem2?.userID ?? '';

      if (getApiOtp.isNotEmpty && getApiOtp != '0000') {
        isUserExist = true;
        startTimer();
        loggedInUserData = loginUserModel.mItem2;

        await LocalStorages.saveUserData(
          localSaveType: LocalSaveType.userid,
          value: userId,
        );

        await getUserRoleListApiCall();
        EasyLoading.showSuccess(ConstantMessage.otpSentSuccessfully);
      } else {
        EasyLoading.showError(ConstantMessage.invalidCrediantials);
      }
    } else {
      EasyLoading.showInfo(ConstantMessage.somethingWentWrongPleaseTryAgain);
    }

    safeNotifyListeners();
  }


  Future<void> handleRoleAndNavigate(MItem2 loginUser) async {
    if (loginUser.rolesInfo == null || loginUser.rolesInfo!.isEmpty) {
      EasyLoading.showError("User has no roles assigned");
      return;
    }

    final List<String> roleCodesFromLogin = loginUser.rolesInfo!
        .map((roleInfo) => roleInfo.roleCode ?? '')
        .where((code) => code.isNotEmpty)
        .toList();

    if (userRoleList.isEmpty) {
      await getUserRoleListApiCall();
    }

    final matchedRole = userRoleList.firstWhere(
          (role) => roleCodesFromLogin.contains(role.roleCode),
      orElse: () => UserRoleModel(),
    );

    printDebug('Matched role: ${matchedRole.roleCode}');

    if (matchedRole.roleCode != null && matchedRole.roleCode!.isNotEmpty) {
      selectedUserRole = matchedRole;
      await LocalStorages.saveUserData(
        localSaveType: LocalSaveType.role,
        value: matchedRole.roleCode,
      );

      navigateToRoleScreen(matchedRole.roleCode!);
      return;
    }

    EasyLoading.showInfo('No matching role found');
  }

  void navigateToRoleScreen(String roleCode) {
    printDebug('Navigating to screen for role $roleCode');
    switch (roleCode) {
      case 'TP':
        NavigateRoutes.navigateTo();
        break;
      case 'STMGR':
        NavigateRoutes.toStoreManagerScreen();
        break;
      case 'STGM':
        NavigateRoutes.toStoreGmScreen();
        break;
      case 'STDGM':
        NavigateRoutes.toStoreDGMScreen();
        break;
      case 'QCMGR':
        NavigateRoutes.toQCManagerScreen();
        break;
      case 'QCGM':
        NavigateRoutes.toQCGMScreen();
        break;
      case 'QCDGM':
        NavigateRoutes.toQCDGMScreen();
        break;
      case 'ADMIN':
        NavigateRoutes.toAdminScreen();
        break;
      default:
        EasyLoading.showError("Unknown role code: $roleCode");
    }
  }

  Future<void> getUserRoleListApiCall() async {
    isLoadData(true);
    userRoleList.clear();
    selectedUserRole = null;

    final HTTPResponse<dynamic> response = await ApiCalling.callApi(
      isLoading: false,
      apiUrl: AppUrls.getUserRoleDetailsUrl,
      apiFunType: APITypes.get,
    );

    if (response.statusCode == 200) {
      printDebug("response ${response.statusCode} ${response.body}");

      try {
        final List<dynamic> jsonList = response.body;
        userRoleList = jsonList
            .map((e) => UserRoleModel.fromJson(e as Map<String, dynamic>))
            .toList();

        print('User Roles loaded: $userRoleList');
      } catch (e) {
        printDebug("Error parsing user role list: $e");
      }
    }

    isLoadData(false);
    safeNotifyListeners();
  }

  Future<bool> getVersionCheckApiCall(double version) async {
    final HTTPResponse<dynamic> response = await ApiCalling.callApi(
      apiFunType: APITypes.get,
      apiUrl: AppUrls.getVersionUrl,
    );
    if (response.statusCode == 200) {
      String res = response.body ?? '0';
      double responseVersion = double.tryParse(res) ?? 0.0;

      if (responseVersion > version) {
        EasyLoading.showInfo('App Update Required');

        if (Platform.isAndroid) {
          Utils.launchInBrowser(Uri.parse(
              "https://play.google.com/store/apps/details?id=com.hmwssb_swc"));
        }

        // Handle iOS link if needed

        safeNotifyListeners();
        return false;
      }
    }
    safeNotifyListeners();
    return true;
  }
}

