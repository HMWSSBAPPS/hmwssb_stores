// ignore_for_file: always_specify_types, avoid_dynamic_calls

class AllSupplierDetailsModel {
  MItem1? mItem1;
  List<AllSupplierDetailsListModel>? mItem2;

  AllSupplierDetailsModel({this.mItem1, this.mItem2});

  AllSupplierDetailsModel.fromJson(Map<String, dynamic> json) {
    mItem1 =
    json['m_Item1'] != null ? MItem1.fromJson(json['m_Item1']) : null;
    if (json['m_Item2'] != null) {
      mItem2 = <AllSupplierDetailsListModel>[];
      json['m_Item2'].forEach((v) {
        mItem2!.add(AllSupplierDetailsListModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (mItem1 != null) {
      data['m_Item1'] = mItem1!.toJson();
    }
    if (mItem2 != null) {
      data['m_Item2'] = mItem2!.map((AllSupplierDetailsListModel v) => v.toJson()).toList();
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['SupplierId'] = supplierId;
    data['AgencyName'] = agencyName;
    data['AgreementValidity'] = agreementValidity;
    data['WorkOrderDate'] = workOrderDate;
    data['AgreementDate'] = agreementDate;
    data['IsActiveStatus'] = isActiveStatus;
    data['CreatedDate'] = createdDate;
    data['ModifiedDate'] = modifiedDate;
    return data;
  }
}
