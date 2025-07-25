class LoginUserModel {
  MItem1? mItem1;
  MItem2? mItem2;

  LoginUserModel({this.mItem1, this.mItem2});

  LoginUserModel.fromJson(Map<String, dynamic> json) {
    mItem1 =
    json['m_Item1'] != null ? new MItem1.fromJson(json['m_Item1']) : null;
    mItem2 =
    json['m_Item2'] != null ? new MItem2.fromJson(json['m_Item2']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.mItem1 != null) {
      data['m_Item1'] = this.mItem1!.toJson();
    }
    if (this.mItem2 != null) {
      data['m_Item2'] = this.mItem2!.toJson();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ResponseCode'] = this.responseCode;
    data['ResponseType'] = this.responseType;
    data['Description'] = this.description;
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
        rolesInfo!.add(new RolesInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['UserName'] = this.userName;
    data['OTP'] = this.oTP;
    data['AgencyName'] = this.agencyName;
    data['MobileNo'] = this.mobileNo;
    if (this.rolesInfo != null) {
      data['RolesInfo'] = this.rolesInfo!.map((v) => v.toJson()).toList();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['UserID'] = this.userID;
    data['RoleCode'] = this.roleCode;
    data['RoleName'] = this.roleName;
    data['WingType'] = this.wingType;
    return data;
  }
}
