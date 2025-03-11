import 'dart:io';

import '../../../../common_imports.dart';
import '../../../core/network/network_index.dart';
import '../../../datamodel/login_model.dart';


class LoginProvider extends ChangeNotifier {
  double appVersion = 0.0;  // This will store the app version

  void setAppVersion(double version) {
    appVersion = version;
    notifyListeners();
  }
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final TextEditingController mobileNoController = TextEditingController();
  final FocusNode mobileNoFocusNode = FocusNode();

  final TextEditingController otpController = TextEditingController();
  final FocusNode otpFocusNode = FocusNode();

  bool isUserExist = false;
  String getApiOtp = Constants.empty;
  int timer = 30;
  void startTimer() {
    timer = 30;
    const Duration oneSec = Duration(seconds: 1);
    Timer.periodic(
      oneSec,
      (Timer t) {
        if (timer < 1) {
          t.cancel();
        } else {
          timer--;
          notifyToAllValues();
        }
      },
    );
  }

  Future<void> getOtpApiCall() async {
    isUserExist = false;
    getApiOtp = Constants.empty;
    mobileNoFocusNode.unfocus();
    String deviceID = Utils.deviceInfo['deviceID'] ?? '';
    String deviceName = Utils.deviceInfo['device'] ?? '';
    String osVersion = Utils.deviceInfo['osVersion'] ?? '';
    String appName = 'STORESAPP';
    String appVersionString = appVersion.toString();

    final HTTPResponse<dynamic> response = await ApiCalling.callApi(
        apiUrl: AppUrls.getLoginOTPExternalUrl,
        apiFunType: APITypes.put,
        sendingData: <String?, dynamic>{
          'mobileNo': mobileNoController.text.trim(),
          "appName": appName,
          "deviceID": deviceID,
          "appVersion": appVersionString,
          "deviceName": deviceName,
          "osVersion": osVersion
        });

    if (response.statusCode == 200) {
      final responseBody = response.body is Map<String, dynamic>
          ? response.body
          : jsonDecode(response.body);

      LoginUserModel loginUserModel = LoginUserModel.fromJson(responseBody);

      // Store OTP and UserName from the response
      getApiOtp = loginUserModel.mItem2?.oTP ?? Constants.empty;
      Object userId = loginUserModel.mItem2?.userID ?? '';

      if (getApiOtp.isNotEmpty && getApiOtp != '0000') {
        isUserExist = true;
        startTimer();

        // Save userName in shared preferences
        await LocalStorages.saveUserData(
            localSaveType: LocalSaveType.userid,
            value: userId);

        EasyLoading.showSuccess(ConstantMessage.otpSentSuccessfully);
      } else {
        EasyLoading.showError(ConstantMessage.invalidCrediantials);
      }
    } else {
      EasyLoading.showInfo(ConstantMessage.somethingWentWrongPleaseTryAgain);
    }

    notifyToAllValues();
  }

  //
  // Future<void> resendOtpApiCall() async {
  //   getApiOtp = Constants.empty;
  //   mobileNoFocusNode.unfocus();
  //   final HTTPResponse<dynamic> response = await ApiCalling.callApi(
  //       apiUrl: AppUrls.resendOTPForAuthorisedManagersUrl,
  //       apiFunType: APITypes.put,
  //       sendingData: <String?, dynamic>{
  //         'mobileNumber': mobileNoController.text.trim()
  //       });
  //
  //   if (response.statusCode == 200) {
  //     getApiOtp = response.body ?? Constants.empty;
  //     if (getApiOtp.isNotEmpty && getApiOtp != '0000') {
  //       startTimer();
  //       EasyLoading.showSuccess(ConstantMessage.otpReSentSuccessfully);
  //     } else {
  //       EasyLoading.showError(ConstantMessage.invalidCrediantials);
  //     }
  //   } else {
  //     EasyLoading.showInfo(ConstantMessage.somethingWentWrongPleaseTryAgain);
  //   }
  //
  //   notifyToAllValues();
  // }

  // Future<bool> loginApiCall() async {
  //   EasyLoading.show(status: Constants.loading);
  //   final HTTPResponse<dynamic> response = await ApiCalling.callApi(
  //       apiFunType: APITypes.post,
  //       apiUrl: AppUrls.loginUrl,
  //       sendingData: <String?, dynamic>{
  //         'mobile_no': mobileNoController.text.trim(),
  //         'password': passwordController.text.trim(),
  //       });

  //   LoginGetModel loginGetModel = LoginGetModel.fromJson(response.body);
  //   if (response.statusCode==200) {
  //     if (loginGetModel.error == 0) {
  //       EasyLoading.showSuccess('Sucessfully Login');

  //       await LocalStorages.saveUserData(
  //           localSaveType: LocalSaveType.token, value: loginGetModel.token);

  //       await LocalStorages.saveUserData(
  //           localSaveType: LocalSaveType.isLoggedIn, value: true);
  //       await LocalStorages.saveUserData(
  //           localSaveType: LocalSaveType.mobileNumber,
  //           value: mobileNoController.text.trim());
  //       // await LocalStorages.saveUserData(
  //       //     localSaveType: LocalSaveType.password,
  //       //     value: passwordController.text.trim());

  //       await LocalStorages.saveUserData(
  //           localSaveType: LocalSaveType.role,
  //           value: loginGetModel.userData?.role?.toLowerCase());

  //       // await LocalStorages.saveUserData(
  //       //     localSaveType: LocalSaveType.selectedCanNo,
  //       //     value: loginGetModel.userData?.canNumbers?.firstOrNull);

  //       // await LocalStorages.saveUserData(
  //       //     localSaveType: LocalSaveType.loginUserData,
  //       //     value: loginGetModel.userData);

  //       NavigateRoutes.navigateTo();
  //       mobileNoController.clear();
  //       passwordController.clear();
  //       EasyLoading.dismiss();

  //       notifyToAllValues();
  //       return true;
  //     }
  //     EasyLoading.dismiss();
  //     EasyLoading.showError(loginGetModel.message ??
  //         ConstantMessage.somethingWentWrongPleaseTryAgain);
  //     notifyToAllValues();

  //     return true;
  //   }

  //   EasyLoading.dismiss();
  //   EasyLoading.showError(loginGetModel.message ??
  //       ConstantMessage.somethingWentWrongPleaseTryAgain);
  //   notifyToAllValues();
  //   return false;
  // }

  final TextEditingController currentPasswordController =
      TextEditingController();
  final FocusNode currentPasswordFocusNode = FocusNode();
  final TextEditingController newPasswordController = TextEditingController();
  final FocusNode newPasswordFocusNode = FocusNode();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final FocusNode confirmPasswordFocusNode = FocusNode();

  void clearChangePassWordValues() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  // Future<void> changePasswordApiCall() async {
  //   EasyLoading.show(status: Constants.loading);
  //   final HTTPResponse<dynamic> response = await ApiCalling.callApi(
  //     apiFunType: APITypes.post,
  //     apiUrl: AppUrls.changePasswordUrl,
  //     sendingData: <String?, dynamic>{
  //       'new_password': newPasswordController.text.trim()
  //     },
  //     token: LocalStorages.getToken() ?? '',
  //   );
  //   if (response.isSuccessful && response.body['error'] == 0) {
  //     LocalStorages.saveUserData(
  //         localSaveType: LocalSaveType.password,
  //         value: newPasswordController.text.trim());
  //   }

  //   ((response.isSuccessful && response.body['error'] == 0)
  //           ? EasyLoading.showSuccess
  //           : EasyLoading.showError)(
  //       response.body['message'] ??
  //           ConstantMessage.somethingWentWrongPleaseTryAgain);
  //   EasyLoading.dismiss();
  //   notifyToAllValues();
  //   return;
  // }

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
        if (Platform.isIOS) {
          // Utils.launchInBrowser(Uri.parse(
          //     "https://apps.apple.com/in/app/com."));
        }

        notifyToAllValues();
        return false;
      }
    }
    notifyToAllValues();
    return true;
  }

  void notifyToAllValues() => notifyListeners();

  @override
  void dispose() {
    mobileNoController.dispose();
    mobileNoFocusNode.dispose();
    otpController.dispose();
    otpFocusNode.dispose();
    super.dispose();
  }
}
