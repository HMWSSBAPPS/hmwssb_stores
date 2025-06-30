class InspectionDetailsModel {
  MItem1? mItem1;
  List<MItem2>? mItem2;
  List<MItem2>? mItem3; // Reusing MItem2 for both sections

  InspectionDetailsModel({this.mItem1, this.mItem2, this.mItem3});

  InspectionDetailsModel.fromJson(Map<String, dynamic> json) {
    mItem1 = json['m_Item1'] != null ? MItem1.fromJson(json['m_Item1']) : null;
    if (json['m_Item2'] != null) {
      mItem2 = List<MItem2>.from(json['m_Item2'].map((x) => MItem2.fromJson(x)));
    }
    if (json['m_Item3'] != null) {
      mItem3 = List<MItem2>.from(json['m_Item3'].map((x) => MItem2.fromJson(x)));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (mItem1 != null) data['m_Item1'] = mItem1!.toJson();
    if (mItem2 != null) data['m_Item2'] = mItem2!.map((v) => v.toJson()).toList();
    if (mItem3 != null) data['m_Item3'] = mItem3!.map((v) => v.toJson()).toList();
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

  Map<String, dynamic> toJson() => {
    'ResponseCode': responseCode,
    'ResponseType': responseType,
    'Description': description,
  };
}

class MItem2 {
  int? pKey;
  int? purchaseOrderID;
  int? purchaseOrderLineItemID;
  double? quantity;
  String? unitType;
  String? gmReadiness;
  String? itemMake;
  double? quantityToInspect;
  String? batchNo;
  String? manufactureDate;
  String? inspectionDate;
  String? inspectionRemarks;
  int? qCDoneBy;
  String? sLAQCChecks;
  String? qCStatus;
  String? createdDate;
  String? hSMNo;
  int? refPKey;
  double? qCApprovedQuantity;
  List<QCInspectionImages>? qCInspectionImages;

  MItem2({
    this.pKey,
    this.purchaseOrderID,
    this.purchaseOrderLineItemID,
    this.quantity,
    this.unitType,
    this.gmReadiness,
    this.itemMake,
    this.quantityToInspect,
    this.batchNo,
    this.manufactureDate,
    this.inspectionDate,
    this.inspectionRemarks,
    this.qCDoneBy,
    this.sLAQCChecks,
    this.qCStatus,
    this.createdDate,
    this.hSMNo,
    this.refPKey,
    this.qCApprovedQuantity,
    this.qCInspectionImages,
  });

  MItem2.fromJson(Map<String, dynamic> json) {
    pKey = json['PKey'];
    purchaseOrderID = json['PurchaseOrderID'];
    purchaseOrderLineItemID = json['PurchaseOrderLineItemID'];
    quantity = (json['Quantity'] as num?)?.toDouble();
    unitType = json['UnitType'];
    gmReadiness = json['GmReadiness'];
    itemMake = json['ItemMake'];
    quantityToInspect = (json['QuantityToInspect'] as num?)?.toDouble();
    batchNo = json['BatchNo'];
    manufactureDate = json['ManufactureDate'];
    inspectionDate = json['InspectionDate'];
    inspectionRemarks = json['InspectionRemarks'];
    qCDoneBy = json['QCDoneBy'];
    sLAQCChecks = json['SLAQCChecks'];
    qCStatus = json['QCStatus'];
    createdDate = json['CreatedDate'];
    hSMNo = json['HSMNo'];
    refPKey = json['RefPKey'];
    qCApprovedQuantity = (json['QCApprovedQuantity'] as num?)?.toDouble();
    if (json['QCInspectionImages'] != null) {
      qCInspectionImages = List<QCInspectionImages>.from(
          json['QCInspectionImages'].map((x) => QCInspectionImages.fromJson(x)));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['PKey'] = pKey;
    data['PurchaseOrderID'] = purchaseOrderID;
    data['PurchaseOrderLineItemID'] = purchaseOrderLineItemID;
    data['Quantity'] = quantity;
    data['UnitType'] = unitType;
    data['GmReadiness'] = gmReadiness;
    data['ItemMake'] = itemMake;
    data['QuantityToInspect'] = quantityToInspect;
    data['BatchNo'] = batchNo;
    data['ManufactureDate'] = manufactureDate;
    data['InspectionDate'] = inspectionDate;
    data['InspectionRemarks'] = inspectionRemarks;
    data['QCDoneBy'] = qCDoneBy;
    data['SLAQCChecks'] = sLAQCChecks;
    data['QCStatus'] = qCStatus;
    data['CreatedDate'] = createdDate;
    data['HSMNo'] = hSMNo;
    data['RefPKey'] = refPKey;
    data['QCApprovedQuantity'] = qCApprovedQuantity;
    if (qCInspectionImages != null) {
      data['QCInspectionImages'] = qCInspectionImages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class QCInspectionImages {
  int? pKey;
  int? refPkey;
  String? imagePath;
  String? imageName;
  String? imageLatitude;
  String? imageLongitude;
  int? imageType;
  String? createdDate;

  QCInspectionImages({
    this.pKey,
    this.refPkey,
    this.imagePath,
    this.imageName,
    this.imageLatitude,
    this.imageLongitude,
    this.imageType,
    this.createdDate,
  });

  QCInspectionImages.fromJson(Map<String, dynamic> json) {
    pKey = json['PKey'];
    refPkey = json['RefPkey'];
    imagePath = json['ImagePath'];
    imageName = json['ImageName'];
    imageLatitude = json['ImageLatitude'];
    imageLongitude = json['ImageLongitude'];
    imageType = json['ImageType'];
    createdDate = json['CreatedDate'];
  }

  Map<String, dynamic> toJson() => {
    'PKey': pKey,
    'RefPkey': refPkey,
    'ImagePath': imagePath,
    'ImageName': imageName,
    'ImageLatitude': imageLatitude,
    'ImageLongitude': imageLongitude,
    'ImageType': imageType,
    'CreatedDate': createdDate,
  };
}
