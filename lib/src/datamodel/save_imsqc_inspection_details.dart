// ignore_for_file: always_specify_types, avoid_dynamic_calls

class SaveIMSQCInspectionDetailsModel {
  int? purchaseOrderID;
  int? purchaseOrderLineItemID;
  double? quantity;
  double? qCApprovedQuantity;
  String? unitType;
  String? gmReadiness;
  String? itemMake;
  String? quantityToInspect;
  String? batchNo;
  String? manufactureDate;
  String? inspectionDate;
  String? inspectionRemarks;
  int? qCDoneBy;
  String? sLAQCChecks;
  String? hSMNo;
  int? refPkey;
  String? qCStatus;
  String? uploadDocName;
  String? uploadDocBase64;
  String? inspectionLevel;
  List<SaveQCInspectionImages>? qCInspectionImages;

  SaveIMSQCInspectionDetailsModel(
      {this.purchaseOrderID,
        this.purchaseOrderLineItemID,
        this.quantity,
        this.qCApprovedQuantity,
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
        this.hSMNo,
        this.refPkey,
        this.qCStatus,
        this.uploadDocName,
        this.uploadDocBase64,
        this.inspectionLevel,
        this.qCInspectionImages});

  SaveIMSQCInspectionDetailsModel.fromJson(Map<String, dynamic> json) {
    purchaseOrderID = json['PurchaseOrderID'];
    purchaseOrderLineItemID = json['PurchaseOrderLineItemID'];
    quantity = json['Quantity'];
    qCApprovedQuantity = json['QCApprovedQuantity'];
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
    hSMNo = json['HSMNo'];
    refPkey = json['RefPkey'];
    qCStatus = json['QCStatus'];
    uploadDocName = json['UploadDocName'];
    uploadDocBase64 = json['UploadDocBase64'];
    inspectionLevel = json['InspectionLevel'];
    if (json['QCInspectionImages'] != null) {
      qCInspectionImages = <SaveQCInspectionImages>[];
      json['QCInspectionImages'].forEach((v) {
        qCInspectionImages!.add(SaveQCInspectionImages.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['PurchaseOrderID'] = purchaseOrderID;
    data['PurchaseOrderLineItemID'] = purchaseOrderLineItemID;
    data['Quantity'] = quantity;
    data['QCApprovedQuantity'] = qCApprovedQuantity;
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
    data['HSMNo'] = hSMNo;
    data['RefPkey'] = refPkey;
    data['QCStatus'] = qCStatus;
    data['UploadDocName'] = uploadDocName;
    data['UploadDocBase64'] = uploadDocBase64;
    data['InspectionLevel'] = inspectionLevel;
    if (qCInspectionImages != null) {
      data['QCInspectionImages'] =
          qCInspectionImages!.map((SaveQCInspectionImages v) => v.toJson()).toList();
    }
    return data;
  }
}

class SaveQCInspectionImages {
  String? appName;
  int? imageType;
  String? imageName;
  String? imageLatitude;
  String? imageLongitude;
  String? base64Image;

  SaveQCInspectionImages(
      {this.appName,
        this.imageType,
        this.imageName,
        this.imageLatitude,
        this.imageLongitude,
        this.base64Image});

  SaveQCInspectionImages.fromJson(Map<String, dynamic> json) {
    appName = json['AppName'];
    imageType = json['ImageType'];
    imageName = json['ImageName'];
    imageLatitude = json['ImageLatitude'];
    imageLongitude = json['ImageLongitude'];
    base64Image = json['Base64Image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['AppName'] = appName;
    data['ImageType'] = imageType;
    data['ImageName'] = imageName;
    data['ImageLatitude'] = imageLatitude;
    data['ImageLongitude'] = imageLongitude;
    data['Base64Image'] = base64Image;
    return data;
  }
}
