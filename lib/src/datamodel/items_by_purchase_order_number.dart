// ignore_for_file: always_specify_types, avoid_dynamic_calls

class ItemsByPurchaseOrderNumberModel {
  MItem1? mItem1;
  List<ItemsByPurchaseOrderModel>? mItem2;

  ItemsByPurchaseOrderNumberModel({this.mItem1, this.mItem2});

  ItemsByPurchaseOrderNumberModel.fromJson(Map<String, dynamic> json) {
    mItem1 =
    json['m_Item1'] != null ? MItem1.fromJson(json['m_Item1']) : null;
    if (json['m_Item2'] != null) {
      mItem2 = <ItemsByPurchaseOrderModel>[];
      json['m_Item2'].forEach((v) {
        mItem2!.add(ItemsByPurchaseOrderModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (mItem1 != null) {
      data['m_Item1'] = mItem1!.toJson();
    }
    if (mItem2 != null) {
      data['m_Item2'] = mItem2!.map((ItemsByPurchaseOrderModel v) => v.toJson()).toList();
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

class ItemsByPurchaseOrderModel {
  int? pkey;
  String? purchaseOrderNo;
  int? lineItemPKey;
  String? itemName;
  double? quantity;
  String? units;
  String? readyNessStatus;
  String? itemMake;
  double? quantitytoInspect;
  int? unitsRate;
  String? slaDate;
  int? refPkey;
  String? agreementNo;
  String? agreementDate;

  ItemsByPurchaseOrderModel(
      {this.pkey,
        this.purchaseOrderNo,
        this.lineItemPKey,
        this.itemName,
        this.quantity,
        this.units,
        this.readyNessStatus,
        this.itemMake,
        this.quantitytoInspect,
        this.unitsRate,
        this.slaDate,
        this.refPkey,
        this.agreementNo,
        this.agreementDate});

  ItemsByPurchaseOrderModel.fromJson(Map<String, dynamic> json) {
    pkey = json['Pkey'];
    purchaseOrderNo = json['PurchaseOrderNo'];
    lineItemPKey = json['LineItemPKey'];
    itemName = json['ItemName'];
    quantity = json['Quantity'];
    units = json['Units'];
    readyNessStatus = json['ReadyNessStatus'];
    itemMake = json['ItemMake'];
    quantitytoInspect = json['QuantitytoInspect'];
    unitsRate = json['UnitsRate'];
    slaDate = json['SlaDate'];
    refPkey = json['RefPkey'];
    agreementNo = json['AgreementNo'];
    agreementDate = json['AgreementDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Pkey'] = pkey;
    data['PurchaseOrderNo'] = purchaseOrderNo;
    data['LineItemPKey'] = lineItemPKey;
    data['ItemName'] = itemName;
    data['Quantity'] = quantity;
    data['Units'] = units;
    data['ReadyNessStatus'] = readyNessStatus;
    data['ItemMake'] = itemMake;
    data['QuantitytoInspect'] = quantitytoInspect;
    data['UnitsRate'] = unitsRate;
    data['SlaDate'] = slaDate;
    data['RefPkey'] = refPkey;
    data['AgreementNo'] = agreementNo;
    data['AgreementDate'] = agreementDate;
    return data;
  }
}
