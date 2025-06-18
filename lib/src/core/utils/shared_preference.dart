import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../common_imports.dart';
import '../../datamodel/login_model.dart';

enum LocalSaveType {
  isLoggedIn,
  name,
  mobileNumber,
  role,
  otp,
  userid,
  wingid,
  fullUserData,
}

class LocalStorages {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static dynamic saveUserData({
    required LocalSaveType localSaveType,
    required dynamic value,
  }) {
    dynamic val = value ?? (localSaveType == LocalSaveType.isLoggedIn ? false : '');
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
    }
  }

  static bool getIsLoggedIn() => _prefs?.getBool(ShareKey.isLoggedIn) ?? false;
  static String getName() => _prefs?.getString(ShareKey.name) ?? Constants.empty;
  static String getMobileNumber() => _prefs?.getString(ShareKey.mobileNumber) ?? Constants.empty;
  static String getRole() => _prefs?.getString(ShareKey.role) ?? Constants.empty;
  static String getOtp() => _prefs?.getString(ShareKey.otp) ?? Constants.empty;
  static int getUserId() => _prefs?.getInt(ShareKey.userId) ?? 0;
  static String getWingId() => _prefs?.getString(ShareKey.wingId) ?? Constants.empty;
  static String? getFullUserDataRaw() => _prefs?.getString(ShareKey.fullUserData);

  static Map<String, dynamic>? getFullUserData() {
    final raw = getFullUserDataRaw();
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw);
    } catch (e) {
      log("Error decoding fullUserData: $e");
      return null;
    }
  }

  static MItem2? getParsedLoginUser() {
    final data = getFullUserData();
    if (data == null) return null;
    try {
      return LoginUserModel.fromJson(data).mItem2;
    } catch (e) {
      log("Error parsing MItem2: $e");
      return null;
    }
  }

  static Future<void> logOutUser() async {
    await _prefs?.clear();
  }
}

class ShareKey {
  static String isLoggedIn = "isloggedin";
  static String name = "name";
  static String mobileNumber = "mobile_number";
  static String role = "role";
  static String userId = "userid";
  static String otp = "otp";
  static String wingId = "wingid";
  static String fullUserData = "full_user_data";
}
