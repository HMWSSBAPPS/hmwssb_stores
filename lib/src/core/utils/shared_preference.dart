import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hmwssb_stores/common_imports.dart';
import 'package:hmwssb_stores/src/datamodel/login_model.dart';

enum LocalSaveType {
  isLoggedIn,
  name,
  mobileNumber,
  role,
  otp,
  roleCode,
  userid,
  wingid,
  fullUserData,
  selectedRoleName, // ✅ NEW
}

class LocalStorages {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static dynamic saveUserData({
    required LocalSaveType localSaveType,
    // ignore: avoid_annotating_with_dynamic
    required dynamic value,
  }) {
    dynamic val = value ?? (localSaveType == LocalSaveType.isLoggedIn ? false : '');
    printDebug(val);
    switch (localSaveType) {
      case LocalSaveType.isLoggedIn:
        _prefs?.setBool(ShareKey.isLoggedIn, val);
        break;
      case LocalSaveType.name:
        _prefs?.setString(ShareKey.name, val);
        break;
      case LocalSaveType.mobileNumber:
        _prefs?.setString(ShareKey.mobileNumber, val);
        break;
      case LocalSaveType.role:
        _prefs?.setString(ShareKey.role, val);
        break;
      case LocalSaveType.roleCode:
        _prefs?.setString(ShareKey.roleCode, val);
        break;
      case LocalSaveType.otp:
        _prefs?.setString(ShareKey.otp, val);
        break;
      case LocalSaveType.userid:
        _prefs?.setInt(ShareKey.userId, val is int ? val : int.tryParse(val.toString()) ?? 0);
        break;
      case LocalSaveType.wingid:
        _prefs?.setString(ShareKey.wingId, val);
        break;
      case LocalSaveType.fullUserData:
        _prefs?.setString(ShareKey.fullUserData, jsonEncode(val));
        break;
      case LocalSaveType.selectedRoleName: // ✅ NEW
        _prefs?.setString(ShareKey.selectedRoleName, val);
        break;
    }
  }

  static bool getIsLoggedIn() => _prefs?.getBool(ShareKey.isLoggedIn) ?? false;
  static String getName() => _prefs?.getString(ShareKey.name) ?? Constants.empty;
  static String getMobileNumber() => _prefs?.getString(ShareKey.mobileNumber) ?? Constants.empty;
  static String getRole() => _prefs?.getString(ShareKey.role) ?? Constants.empty;
  static String getOtp() => _prefs?.getString(ShareKey.otp) ?? Constants.empty;
  static int getUserId() => _prefs?.getInt(ShareKey.userId) ?? 0;
  static String getWingId() => _prefs?.getString(ShareKey.wingId) ?? Constants.empty;
  static String getRoleCode() => _prefs?.getString(ShareKey.roleCode) ?? Constants.empty;
  static String? getFullUserDataRaw() => _prefs?.getString(ShareKey.fullUserData);

  static MItem2? getFullUserData() {
    final String? raw = getFullUserDataRaw();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      return MItem2.fromJson(jsonDecode(raw));
    } on Exception catch (e) {
      log("Error decoding fullUserData: $e");
      return null;
    }
  }

  /// ✅ Get previously selected roleName
  static String getSelectedRoleName() =>
      _prefs?.getString(ShareKey.selectedRoleName) ?? Constants.empty;

  static Future<void> logOutUser() async {
    await _prefs?.clear();
  }
}

class ShareKey {
  static String isLoggedIn = "isloggedin";
  static String name = "name";
  static String mobileNumber = "mobile_number";
  static String role = "role";
  static String otp = "otp";
  static String roleCode = "roleCode";
  static String userId = "userid";
  static String wingId = "wingid";
  static String fullUserData = "full_user_data";
  static String selectedRoleName = "selected_role_name"; // ✅ NEW
}
