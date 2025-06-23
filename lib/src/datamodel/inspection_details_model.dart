class InspectionDetailsModel {
  MItem1? mItem1;
  List<MItem2>? mItem2;

  InspectionDetailsModel({this.mItem1, this.mItem2});

  InspectionDetailsModel.fromJson(Map<String, dynamic> json) {
    mItem1 =
    json['m_Item1'] != null ? new MItem1.fromJson(json['m_Item1']) : null;
    if (json['m_Item2'] != null) {
      mItem2 = <MItem2>[];
      json['m_Item2'].forEach((v) {
        mItem2!.add(new MItem2.fromJson(v));
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

class MItem2 {
  int? pKey;
  int? purchaseOrderID;
  int? purchaseOrderLineItemID;
  int? quantity;
  String? unitType;
  String? gmReadiness;
  String? itemMake;
  int? quantityToInspect;
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
  int? qCApprovedQuantity;
  List<QCInspectionImages>? qCInspectionImages;

  MItem2(
      {this.pKey,
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
        this.qCInspectionImages});

  MItem2.fromJson(Map<String, dynamic> json) {
    pKey = json['PKey'];
    purchaseOrderID = json['PurchaseOrderID'];
    purchaseOrderLineItemID = json['PurchaseOrderLineItemID'];
    quantity = json['Quantity'];
    unitType = json['UnitType'];
    gmReadiness = json['GmReadiness'];
    itemMake = json['ItemMake'];
    quantityToInspect = json['QuantityToInspect'];
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
    qCApprovedQuantity = json['QCApprovedQuantity'];
    if (json['QCInspectionImages'] != null) {
      qCInspectionImages = <QCInspectionImages>[];
      json['QCInspectionImages'].forEach((v) {
        qCInspectionImages!.add(new QCInspectionImages.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['PKey'] = this.pKey;
    data['PurchaseOrderID'] = this.purchaseOrderID;
    data['PurchaseOrderLineItemID'] = this.purchaseOrderLineItemID;
    data['Quantity'] = this.quantity;
    data['UnitType'] = this.unitType;
    data['GmReadiness'] = this.gmReadiness;
    data['ItemMake'] = this.itemMake;
    data['QuantityToInspect'] = this.quantityToInspect;
    data['BatchNo'] = this.batchNo;
    data['ManufactureDate'] = this.manufactureDate;
    data['InspectionDate'] = this.inspectionDate;
    data['InspectionRemarks'] = this.inspectionRemarks;
    data['QCDoneBy'] = this.qCDoneBy;
    data['SLAQCChecks'] = this.sLAQCChecks;
    data['QCStatus'] = this.qCStatus;
    data['CreatedDate'] = this.createdDate;
    data['HSMNo'] = this.hSMNo;
    data['RefPKey'] = this.refPKey;
    data['QCApprovedQuantity'] = this.qCApprovedQuantity;
    if (this.qCInspectionImages != null) {
      data['QCInspectionImages'] =
          this.qCInspectionImages!.map((v) => v.toJson()).toList();
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

  QCInspectionImages(
      {this.pKey,
        this.refPkey,
        this.imagePath,
        this.imageName,
        this.imageLatitude,
        this.imageLongitude,
        this.imageType,
        this.createdDate});

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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['PKey'] = this.pKey;
    data['RefPkey'] = this.refPkey;
    data['ImagePath'] = this.imagePath;
    data['ImageName'] = this.imageName;
    data['ImageLatitude'] = this.imageLatitude;
    data['ImageLongitude'] = this.imageLongitude;
    data['ImageType'] = this.imageType;
    data['CreatedDate'] = this.createdDate;
    return data;
  }
}
