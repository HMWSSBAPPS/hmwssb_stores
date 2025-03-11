class SaveIMSQCInspectionDetailsModel {
  int? purchaseOrderID;
  int? purchaseOrderLineItemID;
  int? quantity;
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
  List<QCInspectionImages>? qCInspectionImages;

  SaveIMSQCInspectionDetailsModel(
      {this.purchaseOrderID,
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
        this.hSMNo,
        this.refPkey,
        this.qCStatus,
        this.uploadDocName,
        this.uploadDocBase64,
        this.qCInspectionImages});

  SaveIMSQCInspectionDetailsModel.fromJson(Map<String, dynamic> json) {
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
    hSMNo = json['HSMNo'];
    refPkey = json['RefPkey'];
    qCStatus = json['QCStatus'];
    uploadDocName = json['UploadDocName'];
    uploadDocBase64 = json['UploadDocBase64'];
    if (json['QCInspectionImages'] != null) {
      qCInspectionImages = <QCInspectionImages>[];
      json['QCInspectionImages'].forEach((v) {
        qCInspectionImages!.add(new QCInspectionImages.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
    data['HSMNo'] = this.hSMNo;
    data['RefPkey'] = this.refPkey;
    data['QCStatus'] = this.qCStatus;
    data['UploadDocName'] = this.uploadDocName;
    data['UploadDocBase64'] = this.uploadDocBase64;
    if (this.qCInspectionImages != null) {
      data['QCInspectionImages'] =
          this.qCInspectionImages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class QCInspectionImages {
  String? appName;
  int? imageType;
  String? imageName;
  String? imageLatitude;
  String? imageLongitude;
  String? base64Image;

  QCInspectionImages(
      {this.appName,
        this.imageType,
        this.imageName,
        this.imageLatitude,
        this.imageLongitude,
        this.base64Image});

  QCInspectionImages.fromJson(Map<String, dynamic> json) {
    appName = json['AppName'];
    imageType = json['ImageType'];
    imageName = json['ImageName'];
    imageLatitude = json['ImageLatitude'];
    imageLongitude = json['ImageLongitude'];
    base64Image = json['Base64Image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['AppName'] = this.appName;
    data['ImageType'] = this.imageType;
    data['ImageName'] = this.imageName;
    data['ImageLatitude'] = this.imageLatitude;
    data['ImageLongitude'] = this.imageLongitude;
    data['Base64Image'] = this.base64Image;
    return data;
  }
}
