class UserRoleModel {
  int? roleID;
  String? roleCode;
  String? roleName;

  UserRoleModel({this.roleID, this.roleCode, this.roleName});

  UserRoleModel.fromJson(Map<String, dynamic> json) {
    roleID = json['RoleID'];
    roleCode = json['RoleCode'];
    roleName = json['RoleName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['RoleID'] = roleID;
    data['RoleCode'] = roleCode;
    data['RoleName'] = roleName;
    return data;
  }
}
