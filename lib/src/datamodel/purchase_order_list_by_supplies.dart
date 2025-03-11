class PurchaseOrderListBySuppliesModel {
  MItem1? mItem1;
  List<PurchaseOrderListMode>? mItem2;

  PurchaseOrderListBySuppliesModel({this.mItem1, this.mItem2});

  PurchaseOrderListBySuppliesModel.fromJson(Map<String, dynamic> json) {
    mItem1 =
    json['m_Item1'] != null ? new MItem1.fromJson(json['m_Item1']) : null;
    if (json['m_Item2'] != null) {
      mItem2 = <PurchaseOrderListMode>[];
      json['m_Item2'].forEach((v) {
        mItem2!.add(new PurchaseOrderListMode.fromJson(v));
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

class PurchaseOrderListMode {
  int? pkey;
  String? purchaseorderno;

  PurchaseOrderListMode({this.pkey, this.purchaseorderno});

  PurchaseOrderListMode.fromJson(Map<String, dynamic> json) {
    pkey = json['Pkey'];
    purchaseorderno = json['Purchaseorderno'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Pkey'] = this.pkey;
    data['Purchaseorderno'] = this.purchaseorderno;
    return data;
  }
}
