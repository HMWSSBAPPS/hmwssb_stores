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
  String? agreementValidity;
  String? workOrderDate;
  String? agreementDate;
  int? isActiveStatus;
  String? createdDate;
  String? modifiedDate;

  AllSupplierDetailsListModel(
      {this.supplierId,
        this.agencyName,
        this.agreementValidity,
        this.workOrderDate,
        this.agreementDate,
        this.isActiveStatus,
        this.createdDate,
        this.modifiedDate});

  AllSupplierDetailsListModel.fromJson(Map<String, dynamic> json) {
    supplierId = json['SupplierId'];
    agencyName = json['AgencyName'];
    agreementValidity = json['AgreementValidity'];
    workOrderDate = json['WorkOrderDate'];
    agreementDate = json['AgreementDate'];
    isActiveStatus = json['IsActiveStatus'];
    createdDate = json['CreatedDate'];
    modifiedDate = json['ModifiedDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SupplierId'] = this.supplierId;
    data['AgencyName'] = this.agencyName;
    data['AgreementValidity'] = this.agreementValidity;
    data['WorkOrderDate'] = this.workOrderDate;
    data['AgreementDate'] = this.agreementDate;
    data['IsActiveStatus'] = this.isActiveStatus;
    data['CreatedDate'] = this.createdDate;
    data['ModifiedDate'] = this.modifiedDate;
    return data;
  }
}
