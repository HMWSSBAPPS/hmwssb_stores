class AllSupplierDetailsModel {
  MItem1? mItem1;
  List<AllSupplierDetailsListModel>? mItem2;

  AllSupplierDetailsModel({this.mItem1, this.mItem2});

  AllSupplierDetailsModel.fromJson(Map<String, dynamic> json) {
    mItem1 =
    json['m_Item1'] != null ? new MItem1.fromJson(json['m_Item1']) : null;
    if (json['m_Item2'] != null) {
      mItem2 = <AllSupplierDetailsListModel>[];
      json['m_Item2'].forEach((v) {
        mItem2!.add(new AllSupplierDetailsListModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.mItem1 != null) {
      data['m_Item1'] = this.mItem1!.toJson();
    }
    if (this.mItem2 != null) {
      data['m_Item2'] = this.mItem2!.map((v) => v.toJson()).toList();
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

class AllSupplierDetailsListModel {
  int? supplierId;
  String? agencyName;
  String? address;
  String? mobileNo;
  String? agreementValidity;
  String? workOrderNo;
  String? workOrderDate;
  String? agreementDate;
  String? regNo;
  String? gst;
  String? contactPerson;
  String? email;
  int? isActiveStatus;
  String? createdDate;
  String? createdBy;
  String? modifiedDate;

  AllSupplierDetailsListModel(
      {this.supplierId,
        this.agencyName,
        this.address,
        this.mobileNo,
        this.agreementValidity,
        this.workOrderNo,
        this.workOrderDate,
        this.agreementDate,
        this.regNo,
        this.gst,
        this.contactPerson,
        this.email,
        this.isActiveStatus,
        this.createdDate,
        this.createdBy,
        this.modifiedDate});

  AllSupplierDetailsListModel.fromJson(Map<String, dynamic> json) {
    supplierId = json['SupplierId'];
    agencyName = json['AgencyName'];
    address = json['Address'];
    mobileNo = json['MobileNo'];
    agreementValidity = json['AgreementValidity'];
    workOrderNo = json['WorkOrderNo'];
    workOrderDate = json['WorkOrderDate'];
    agreementDate = json['AgreementDate'];
    regNo = json['RegNo'];
    gst = json['Gst'];
    contactPerson = json['ContactPerson'];
    email = json['Email'];
    isActiveStatus = json['IsActiveStatus'];
    createdDate = json['CreatedDate'];
    createdBy = json['CreatedBy'];
    modifiedDate = json['ModifiedDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SupplierId'] = this.supplierId;
    data['AgencyName'] = this.agencyName;
    data['Address'] = this.address;
    data['MobileNo'] = this.mobileNo;
    data['AgreementValidity'] = this.agreementValidity;
    data['WorkOrderNo'] = this.workOrderNo;
    data['WorkOrderDate'] = this.workOrderDate;
    data['AgreementDate'] = this.agreementDate;
    data['RegNo'] = this.regNo;
    data['Gst'] = this.gst;
    data['ContactPerson'] = this.contactPerson;
    data['Email'] = this.email;
    data['IsActiveStatus'] = this.isActiveStatus;
    data['CreatedDate'] = this.createdDate;
    data['CreatedBy'] = this.createdBy;
    data['ModifiedDate'] = this.modifiedDate;
    return data;
  }
}
