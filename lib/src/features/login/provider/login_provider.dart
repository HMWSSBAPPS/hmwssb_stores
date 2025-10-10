// login_provider.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../core/network/network_index.dart';
import '../../../datamodel/login_model.dart';
import '../../../datamodel/userRole_model.dart';
import '../../../../common_imports.dart';

class LoginProvider extends ChangeNotifier {
  double appVersion = 0.0;
  bool isLoading = false;

  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final TextEditingController mobileNoController = TextEditingController();
  final FocusNode mobileNoFocusNode = FocusNode();
  final TextEditingController otpController = TextEditingController();
  final FocusNode otpFocusNode = FocusNode();

  final TextEditingController currentPasswordController =
      TextEditingController();
  final FocusNode currentPasswordFocusNode = FocusNode();
  final TextEditingController newPasswordController = TextEditingController();
  final FocusNode newPasswordFocusNode = FocusNode();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final FocusNode confirmPasswordFocusNode = FocusNode();
  String get userId => LocalStorages.getUserId().toString();
  String get wingId => LocalStorages.getWingId();
  String get roleCode => LocalStorages.getRoleCode();
  String get selectedRoleName => LocalStorages.getSelectedRoleName();
  MItem2? loggedInUserData;
  bool isUserExist = false;
  String getApiOtp = Constants.empty;
  int timer = 30;

  UserRoleModel? selectedUserRole;
  List<UserRoleModel> userRoleList = <UserRoleModel>[];

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
    if (!_isDisposed) notifyListeners();
  }

  void notifyToAllValues() => safeNotifyListeners();

  void setAppVersion(double version) {
    appVersion = version;
    notifyToAllValues();
  }

  void isLoadData(bool loading) {
    isLoading = loading;
    // safeNotifyListeners();
  }

  void startTimer() {
    timer = 30;
    const Duration oneSec = Duration(seconds: 1);
    Timer.periodic(oneSec, (Timer t) {
      if (timer < 1) {
        t.cancel();
      } else {
        timer--;
        notifyToAllValues();
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

    final MItem2? userJson = LocalStorages.getFullUserData();
    if (userJson != null) {
      loggedInUserData = userJson;
      await handleRoleAndNavigate(loggedInUserData!);
    } else {
      EasyLoading.showError("User data not found");
    }
  }
// Expose roles and selectedRole to GlobalAppBar
//   List<UserRoleModel> get roles => userRoleList;
//   UserRoleModel? get selectedRole => selectedUserRole;

  List<Map<String, String>> loginUserRolesMap = [];
  Map<String, String> selectedRole = {};

  Future<void> selectRole() async {
    loginUserRolesMap.clear();

    final fullUserData = LocalStorages.getFullUserData();
    final rolesInfo = fullUserData?.rolesInfo;
    final savedRoleName = LocalStorages.getSelectedRoleName();

    if (rolesInfo == null || rolesInfo.isEmpty) {
      printDebug("❌ No roles found in stored user data.");
      return;
    }

    loginUserRolesMap = rolesInfo
        .map((e) => {
              "userID": "${e.userID}",
              "wingType": "${e.wingType}",
              "roleName": "${e.roleName}",
              "roleCode": "${e.roleCode}",
            })
        .toList();

    if (loginUserRolesMap.isNotEmpty) {
      // Only restore if a saved role exists
      if (savedRoleName != null && savedRoleName.isNotEmpty) {
        selectedRole = loginUserRolesMap.firstWhere(
          (role) => role['roleName'] == savedRoleName,
          orElse: () => loginUserRolesMap.first,
        );
      } else {
        selectedRole = loginUserRolesMap.first;
      }

      await saveSelectedRoleLocally(selectedRole);
    }
  }

  Future<void> saveSelectedRoleLocally(Map<String, String> role) async {
    selectedRole = role;

    await LocalStorages.saveUserData(
      localSaveType: LocalSaveType.userid,
      value: role['userID'] ?? '',
    );
    await LocalStorages.saveUserData(
      localSaveType: LocalSaveType.wingid,
      value: role['wingType'] ?? '',
    );
    await LocalStorages.saveUserData(
      localSaveType: LocalSaveType.selectedRoleName,
      value: role['roleName'] ?? '',
    );
    await LocalStorages.saveUserData(
      localSaveType: LocalSaveType.roleCode,
      value: role['roleCode'] ?? '', // ✅ THIS IS WHAT YOU NEED LATER
    );

    notifyToAllValues();
  }

  // void selectRole()async{
  //   loginUserRolesMap=[];
  //   if(LocalStorages.getFullUserData()!=null){
  //     final rolesInfo = LocalStorages.getFullUserData()?.rolesInfo;
  //
  //     if (rolesInfo != null && rolesInfo.isNotEmpty) {
  //       for (var e in rolesInfo) {
  //         loginUserRolesMap.add({
  //           "userID": "${e.userID}",
  //           "wingType": "${e.wingType}",
  //           "roleName": "${e.roleName}",
  //           "roleCode": "${e.roleCode}",
  //         });
  //       }
  //       if(loginUserRolesMap.isNotEmpty){
  //         selectedRole=loginUserRolesMap.first;
  //         await LocalStorages.saveUserData(localSaveType: LocalSaveType.userid, value: selectedRole['userID']??'' );
  //         await LocalStorages.saveUserData(
  //             localSaveType: LocalSaveType.wingid,
  //             value: selectedRole['wingType']?? ''
  //         );
  //       }
  //     }
  //     // loginUserRolesMap =
  //   }
  //   // notifyToAllValues();
  // }

// Allow GlobalAppBar to update selected role
//   void setSelectedRole(UserRoleModel role) async {
//     selectedUserRole = role;
//     await LocalStorages.saveUserData(localSaveType: LocalSaveType.role, value: role.roleCode);
//     final matchedLoginRole = loggedInUserData?.rolesInfo?.firstWhere(
//           (info) => info.roleCode == role.roleCode,
//       orElse: () => RolesInfo(),
//     );
//     await LocalStorages.saveUserData(
//       localSaveType: LocalSaveType.wingid,
//       value: matchedLoginRole?.wingType ?? '',
//     );
//     safeNotifyListeners();
//   }

  Future<void> getOtpApiCall() async {
    isUserExist = false;
    getApiOtp = Constants.empty;
    mobileNoFocusNode.unfocus();
    await Utils.fetchDeviceInfo();

    final Map<String, String> deviceInfo = Utils.deviceInfo;
    final HTTPResponse<dynamic> response = await ApiCalling.callApi(
      apiUrl: AppUrls.getLoginOTPExternalUrl,
      apiFunType: APITypes.post,
      sendingData: {
        'mobileNo': mobileNoController.text.trim(),
        'appName': 'STORESAPP',
        'deviceID': deviceInfo["deviceID"] ?? '',
        'appVersion': appVersion.toString(),
        'deviceName': deviceInfo["device"] ?? '',
        'osVersion': deviceInfo["osVersion"] ?? '',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = response.body is Map<String, dynamic>
          ? response.body
          : jsonDecode(response.body);
      LoginUserModel loginUserModel = LoginUserModel.fromJson(responseBody);
      final mItem2 = loginUserModel.mItem2;
      final otp = mItem2?.oTP ?? '';

      if (otp.isNotEmpty && otp != '0000') {
        isUserExist = true;
        getApiOtp = otp;
        loggedInUserData = mItem2;
        startTimer();

        await LocalStorages.saveUserData(
            localSaveType: LocalSaveType.userid,
            value: mItem2?.rolesInfo?.first.userID);
        await LocalStorages.saveUserData(
            localSaveType: LocalSaveType.wingid,
            value: mItem2?.rolesInfo?.first.wingType ?? '');
        await LocalStorages.saveUserData(
            localSaveType: LocalSaveType.fullUserData, value: mItem2);

        await getUserRoleListApiCall();
        EasyLoading.showSuccess(ConstantMessage.otpSentSuccessfully);
      } else {
        EasyLoading.showError(ConstantMessage.invalidCrediantials);
      }
    } else {
      EasyLoading.showInfo(ConstantMessage.somethingWentWrongPleaseTryAgain);
    }

    notifyToAllValues();
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

    final matchedLoginRole = loginUser.rolesInfo?.firstWhere(
      (roleInfo) => roleInfo.roleCode == matchedRole.roleCode,
      orElse: () => RolesInfo(),
    );

    if (matchedRole.roleCode != null && matchedRole.roleCode!.isNotEmpty) {
      selectedUserRole = matchedRole;

      await LocalStorages.saveUserData(
          localSaveType: LocalSaveType.role, value: matchedRole.roleCode);
      await LocalStorages.saveUserData(
          localSaveType: LocalSaveType.wingid,
          value: matchedLoginRole?.wingType ?? '');

      navigateToRoleScreen(matchedRole.roleCode!);
    } else {
      EasyLoading.showInfo('No matching role found');
    }
  }

  void navigateToRoleScreen(String roleCode) {
    switch (roleCode) {
      case 'TP':
        NavigateRoutes.toRoleScreen(roleCode);
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
      try {
        final List<dynamic> jsonList = response.body;
        userRoleList = jsonList
            .map((e) => UserRoleModel.fromJson(e as Map<String, dynamic>))
            .toList();
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
      double responseVersion = double.tryParse(response.body ?? '0') ?? 0.0;
      if (responseVersion > version) {
        await EasyLoading.showInfo('App Update Required',
            duration: const Duration(seconds: 5));
        if (Platform.isAndroid) {
          await Utils.launchInBrowser(Uri.parse(
              "https://play.google.com/store/apps/details?id=com.hmwssb_stores"));
        }
        if (Platform.isIOS) {
          // await Utils.launchInBrowser(Uri.parse("https://apps.apple.com/us/app/hmwssb-stores/id6448606970"));
        }
        return false;
      }
    }

    return true;
  }
}
