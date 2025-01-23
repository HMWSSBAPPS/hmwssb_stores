import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common_imports.dart';


enum LocalSaveType {
  isLoggedIn,
  name,
  mobileNumber,
  role,
  otp,
  // token,
  // isActive,
}

class LocalStorages {
  static SharedPreferences? _prefs;

  ///INTIALIZE THE SHARED PREFERENCE STATE
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  ///SAVE THE USER DATA
  static dynamic saveUserData({
    required LocalSaveType localSaveType,
    // ignore: avoid_annotating_with_dynamic
    required dynamic value,
  }) {
    dynamic val =
        value ?? (localSaveType == LocalSaveType.isLoggedIn ? false : '');
    log("local save $localSaveType and $val");

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
    }
  }


  ///GET IS LOGGED IN
  static dynamic getIsLoggedIn() =>
      _prefs?.getBool(ShareKey.isLoggedIn) ?? false;

  ///GET NAME
  static dynamic getName() =>
      _prefs?.getString(ShareKey.name) ?? Constants.empty;

  ///GET IS ACTIVE
  // static dynamic getIsActive() => _prefs?.getBool(ShareKey.isActive) ?? false;

  ///GET MOBILE NUMBER
  static dynamic getMobileNumber() =>
      _prefs?.getString(ShareKey.mobileNumber) ?? Constants.empty;

  ///GET MOBILE
  // static dynamic getMobile() => _prefs?.getString(ShareKey.MOBILE);

  ///GET ROLE
  static dynamic getRole() =>
      _prefs?.getString(ShareKey.role) ?? Constants.empty;

  ///GET OTP
  static dynamic getOtp() => _prefs?.getString(ShareKey.otp) ?? Constants.empty;

  ///GET TOKEN
  // static dynamic getToken() => _prefs?.getString(ShareKey.token);

  static Future<dynamic> logOutUser() async {
    _prefs?.setBool(ShareKey.isLoggedIn, false);
    _prefs?.setString(ShareKey.name, Constants.empty);
    _prefs?.setString(ShareKey.mobileNumber, Constants.empty);
    _prefs?.setString(ShareKey.role, Constants.empty);
    _prefs?.setString(ShareKey.otp, Constants.empty);
    // _prefs?.setString(ShareKey.token, Constants.empty);
    // _prefs?.setString(ShareKey.isActive, Constants.empty);
    _prefs?.clear();
  }

  // static dynamic _clearAllStorage() => _prefs?.clear();
}

class ShareKey {
  static String isLoggedIn = "isloggedin";
  static String name = "name";
  static String mobileNumber = "mobile_number";
  static String role = "role";
  // static String token = "token";
  static String otp = "otp";
  // static String isActive = "isactive";
}
