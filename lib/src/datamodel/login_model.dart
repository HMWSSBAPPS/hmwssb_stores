// ignore_for_file: always_specify_types, avoid_dynamic_calls

class LoginUserModel {
  MItem1? mItem1;
  MItem2? mItem2;

  LoginUserModel({this.mItem1, this.mItem2});

  LoginUserModel.fromJson(Map<String, dynamic> json) {
    mItem1 =
    json['m_Item1'] != null ? MItem1.fromJson(json['m_Item1']) : null;
    mItem2 =
    json['m_Item2'] != null ? MItem2.fromJson(json['m_Item2']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (mItem1 != null) {
      data['m_Item1'] = mItem1!.toJson();
    }
    if (mItem2 != null) {
      data['m_Item2'] = mItem2!.toJson();
    }
    return data;
  }
}

class MItem1 {
  String? responseCode;
  String? responseType;
  String? description;

  MItem1({this.responseCode, this.responseType, this.description});

  MItem1.fromJson(Map<String, dynamic> json) {
    responseCode = json['ResponseCode'];
    responseType = json['ResponseType'];
    description = json['Description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ResponseCode'] = responseCode;
    data['ResponseType'] = responseType;
    data['Description'] = description;
    return data;
  }
}

class MItem2 {
  String? userName;
  String? oTP;
  String? agencyName;
  int? mobileNo;
  List<RolesInfo>? rolesInfo;

  MItem2(
      {this.userName,
        this.oTP,
        this.agencyName,
        this.mobileNo,
        this.rolesInfo});

  MItem2.fromJson(Map<String, dynamic> json) {
    userName = json['UserName'];
    oTP = json['OTP'];
    agencyName = json['AgencyName'];
    mobileNo = json['MobileNo'];
    if (json['RolesInfo'] != null) {
      rolesInfo = <RolesInfo>[];
      json['RolesInfo'].forEach((v) {
        rolesInfo!.add(RolesInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['UserName'] = userName;
    data['OTP'] = oTP;
    data['AgencyName'] = agencyName;
    data['MobileNo'] = mobileNo;
    if (rolesInfo != null) {
      data['RolesInfo'] = rolesInfo!.map((RolesInfo v) => v.toJson()).toList();
    }
    return data;
  }
}

class RolesInfo {
  int? userID;
  String? roleCode;
  String? roleName;
  String? wingType;

  RolesInfo({this.userID, this.roleCode, this.roleName, this.wingType});

  RolesInfo.fromJson(Map<String, dynamic> json) {
    userID = json['UserID'];
    roleCode = json['RoleCode'];
    roleName = json['RoleName'];
    wingType = json['WingType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['UserID'] = userID;
    data['RoleCode'] = roleCode;
    data['RoleName'] = roleName;
    data['WingType'] = wingType;
    return data;
  }
}
