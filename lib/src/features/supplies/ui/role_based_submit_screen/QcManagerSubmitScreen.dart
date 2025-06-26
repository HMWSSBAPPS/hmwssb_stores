// Imports
import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:hmwssb_stores/src/features/login/login_index.dart';
import 'package:hmwssb_stores/src/features/supplies/provider/supplier_provider.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../../../../../common_imports.dart';
import '../../../../datamodel/inspection_details_model.dart';
import '../../../../datamodel/items_by_purchase_order_number.dart';
import '../../../../datamodel/purchase_order_list_by_supplies.dart';
import '../../../../datamodel/save_imsqc_inspection_details.dart';
import 'package:hmwssb_stores/src/datamodel/save_imsqc_inspection_details.dart' as submit;

class QcManagerSubmitScreen extends StatefulWidget {
  const QcManagerSubmitScreen({required this.data, super.key});
  final ItemsByPurchaseOrderModel data;

  @override
  _QcManagerSubmitScreenState createState() => _QcManagerSubmitScreenState();
}

class _QcManagerSubmitScreenState extends State<QcManagerSubmitScreen> {
  late SupplierProvider supplierProvider;
  late LoginProvider loginProvider;
  TextEditingController itemMakeController = TextEditingController();
  TextEditingController batchNoController = TextEditingController();
  TextEditingController inspectionRemarksController = TextEditingController();
  TextEditingController slaForQcController = TextEditingController();
  TextEditingController proposedQuantityController = TextEditingController();
  TextEditingController quantityToInspectController = TextEditingController();
  TextEditingController approvedQuantityController = TextEditingController();
  TextEditingController hsnNoFieldController = TextEditingController();
  String? selectedYearOfManufacturerDisplay;
  String? selectedYearOfManufacturerAPI;
  String? selectedDateOfQCInspectionDisplay;
  String? selectedDateOfQCInspectionAPI;
  String? selectedApprovalStatus;
  String? uploadedFileName;
  String? uploadedFileBase64;
  List<XFile> selectedImages = [];
  int? _currentImageIndex;

  @override
  void initState() {
    super.initState();
    supplierProvider = Provider.of(context, listen: false);
    loginProvider = Provider.of(context, listen: false);
    Utils.callLocApi();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final selectedItem = widget.data;

      final pkey = selectedItem.pkey?.toString().trim();
      if (pkey != null && pkey.isNotEmpty) {
        supplierProvider.selectedPurchaseOrderListBySupplies = PurchaseOrderListMode(
          pkey: selectedItem.pkey,
          purchaseorderno: selectedItem.purchaseOrderNo,
        );
      }

      slaForQcController.text = selectedItem.slaDate != null
          ? DateFormat('dd-MM-yyyy').format(DateTime.parse(selectedItem.slaDate!))
          : '';

      proposedQuantityController.text = selectedItem.quantity?.toString() ?? '';
      quantityToInspectController.text = selectedItem.quantitytoInspect?.toString() ?? '';

      await supplierProvider.getTpInspectionDetailsApiCall(loginProvider);
    });
  }

  Future<void> _submitForm() async {
    DateTime? inspectionDate;
    DateTime? manufactureDate;

    if (selectedDateOfQCInspectionAPI != null && selectedDateOfQCInspectionAPI!.isNotEmpty) {
      inspectionDate = DateTime.tryParse(selectedDateOfQCInspectionAPI!);
      if (inspectionDate == null) {
        EasyLoading.showError('Invalid QC Inspection Date.');
        return;
      }
    }

    if (selectedYearOfManufacturerAPI != null && selectedYearOfManufacturerAPI!.isNotEmpty) {
      manufactureDate = DateTime.tryParse(selectedYearOfManufacturerAPI!);
      if (manufactureDate == null) {
        EasyLoading.showError('Invalid Manufacturing Date.');
        return;
      }

      if (inspectionDate != null && inspectionDate.isBefore(manufactureDate)) {
        EasyLoading.showError('QC Inspection Date should be greater than or equal to the Manufacturing Date.');
        return;
      }
    }

    if (selectedApprovalStatus == "Rejected" && inspectionRemarksController.text.trim().isEmpty) {
      EasyLoading.showError('Inspection Remarks are required for rejected QC.');
      return;
    }

    List<submit.QCInspectionImages> imagesList = selectedImages.map((image) {
      return submit.QCInspectionImages(
        appName: "STORESAPP",
        imageType: selectedImages.indexOf(image) + 1,
        imageName: image.name,
        imageLatitude: Utils.currentPosition?.latitude.toString() ?? "0.0",
        imageLongitude: Utils.currentPosition?.longitude.toString() ?? "0.0",
        base64Image: base64Encode(File(image.path).readAsBytesSync()),
      );
    }).toList();

    final double? approvedQuantity = double.tryParse(approvedQuantityController.text.trim());
    final double? quantity = widget.data.quantity?.toDouble();

    if (selectedApprovalStatus == "Rejected" && (approvedQuantity == null || approvedQuantity != 0)) {
      EasyLoading.showError('Approved Quantity must be 0 because QC Status is Rejected.');
      return;
    }

    final String wingType = LocalStorages.getWingId();
    SaveIMSQCInspectionDetailsModel postData = SaveIMSQCInspectionDetailsModel(
      purchaseOrderID: supplierProvider.selectedPurchaseOrderListBySupplies?.pkey,
      purchaseOrderLineItemID: widget.data.lineItemPKey,
      quantity: quantity,
      qCApprovedQuantity: approvedQuantity,
      unitType: widget.data.units,
      gmReadiness: widget.data.readyNessStatus,
      itemMake: itemMakeController.text,
      quantityToInspect: widget.data.quantitytoInspect.toString(),
      batchNo: batchNoController.text,
      manufactureDate: selectedYearOfManufacturerAPI ?? '',
      inspectionDate: selectedDateOfQCInspectionAPI ?? '',
      inspectionRemarks: inspectionRemarksController.text,
      hSMNo: hsnNoFieldController.text,
      refPkey: widget.data.refPkey,
      qCDoneBy: LocalStorages.getUserId(),
      qCStatus: selectedApprovalStatus ?? '',
      sLAQCChecks: widget.data.slaDate,
      inspectionLevel: wingType,
      uploadDocName: uploadedFileName ?? '',
      uploadDocBase64: uploadedFileBase64 ?? '',
      qCInspectionImages: imagesList,
    );

    await supplierProvider.postIMSQInspectDetailsApiCall(postData, supplierProvider);
  }

  Future<void> _captureImage() async {
    if (selectedImages.length < 5) {
      final image = await Utils.openCamera(getBase64: false);
      if (image != null && image is XFile) {
        setState(() {
          selectedImages.add(image);
        });
      }
    } else {
      EasyLoading.showInfo('You can only upload 5 images.');
    }
  }

  void _removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  void _openFullScreenImage(int index) {
    setState(() {
      _currentImageIndex = index;
    });

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: PhotoViewGallery.builder(
            itemCount: selectedImages.length,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: FileImage(File(selectedImages[index].path)),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered,
              );
            },
            scrollPhysics: BouncingScrollPhysics(),
            backgroundDecoration: BoxDecoration(color: Colors.black),
            pageController: PageController(initialPage: _currentImageIndex ?? 0),
            onPageChanged: (int index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    supplierProvider = Provider.of(context);
    return CommonAppBar(
      bodyWidget: ListView(
        children: <Widget>[
          buildMergedDetailsCard(),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomDropdown<String>(
                  labelStyle: ThemeTextStyle.style(),
                  items: const <String>['Select', 'Approved', 'Rejected'],
                  itemLabel: (String item) => item,
                  value: selectedApprovalStatus ?? 'Select',
                  hintText: 'QC Status',
                  labelName: 'QC Status*',
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedApprovalStatus = newValue;
                    });
                  },
                ),
                const SizedBox(height: 20),
                CustomText(writtenText: "Inspection Remarks", textStyle: ThemeTextStyle.style()),
                const SizedBox(height: 10),
                CustomTextFormField(controller: inspectionRemarksController, focusNode: FocusNode()),
                const SizedBox(height: 20),

                // Upload & Save
                CustomText(writtenText: "Upload QC Reports and Photos", textStyle: ThemeTextStyle.style()),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
                  itemCount: selectedImages.length + (selectedImages.length < 5 ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == selectedImages.length) {
                      return GestureDetector(
                        onTap: _captureImage,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add_a_photo, size: 40, color: Colors.blue),
                        ),
                      );
                    }
                    return GestureDetector(
                      onTap: () => _openFullScreenImage(index),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: FileImage(File(selectedImages[index].path)),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey),
                            ),
                          ),
                          Positioned(
                            top: 5,
                            right: 5,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Icon(Icons.remove_circle, color: Colors.red, size: 24),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                // Input form fields here (like approval dropdown, remarks, etc)
                // Save Button
                Center(
                  child: SubmitButtonFillWidget(
                    onTap: () {
                      if (_validateForm()) {
                        _submitForm();
                      }
                    },
                    text: 'Save',
                    btnColor: ThemeColors.primaryColor,
                    isEnabled: selectedImages.isNotEmpty &&
                        (selectedApprovalStatus != "Rejected" ||
                            inspectionRemarksController.text.trim().isNotEmpty),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildRow(String label, String value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("$label:", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value),
          ],
        ),
      ),
    );
  }

  Widget _buildDoubleRow(String label1, String value1, String label2, String value2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRow(label1, value1),
          _buildRow(label2, value2),
        ],
      ),
    );
  }

  Widget buildMergedDetailsCard() {
    final data = widget.data;

    final mItem2Recs = supplierProvider.inspectionDetailRecords
        .where((r) => r.purchaseOrderLineItemID == data.lineItemPKey)
        .toList();

    final mItem3Recs = supplierProvider.inspectionDetailRecordsAdditional
        .where((r) => r.purchaseOrderLineItemID == data.lineItemPKey)
        .toList();

    final record = mItem2Recs.isNotEmpty ? mItem2Recs.first : null;
    final additionalRecord = mItem3Recs.isNotEmpty ? mItem3Recs.first : null;

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Purchase Order Details', style: Theme.of(context).textTheme.titleLarge,),
            const SizedBox(height: 12),
            _buildDoubleRow('Item Name', data.itemName ?? '-', 'Proposed Quantity', '${data.quantity ?? '-'}'),
            _buildDoubleRow('Units', data.units ?? '-', 'Quantity to Inspect', '${data.quantitytoInspect ?? '-'}'),
            _buildDoubleRow('Units Rate', data.unitsRate?.toString() ?? '-', 'SLA Date', _formatDate(data.slaDate)),
            _buildDoubleRow('Agreement No', data.agreementNo ?? '-', 'Agreement Date', _formatDate(data.agreementDate)),
            _buildDoubleRow('Readiness Status', data.readyNessStatus ?? '-', '', ''),
            const SizedBox(height: 20),

            if (record != null) ...[
              Text('Third Party Inspection Details', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              _buildInspectionSection(record),
            ] else ...[
              const Text('No Third Party Inspection Details data available', style: TextStyle(color: Colors.grey)),
            ],

            const SizedBox(height: 20),
            if (additionalRecord != null) ...[
              Text('Stores Data Inspection Details', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              _buildStoresInspectionSection(additionalRecord),
            ] else ...[
              const Text('No Stores Data Inspection Details data available', style: TextStyle(color: Colors.grey)),
            ]
          ],
        ),
      ),
    );
  }



  Widget _buildInspectionSection(MItem2 record) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDoubleRow('Item Make', record.itemMake ?? '-', 'Batch No', record.batchNo ?? '-'),
        _buildDoubleRow('GM Readiness', record.gmReadiness ?? '-', 'Manufacture Date', _formatDate(record.manufactureDate)),
        _buildDoubleRow('Inspection Date', _formatDate(record.inspectionDate), 'Remarks', record.inspectionRemarks ?? '-'),
        _buildDoubleRow('Status', record.qCStatus ?? '-', 'Approved Quantity', record.qCApprovedQuantity?.toString() ?? '-'),
        _buildDoubleRow('Quantity to Inspect', record.quantityToInspect?.toString() ?? '-', 'Unit Type', record.unitType ?? '-'),
        _buildDoubleRow('HSM No', record.hSMNo ?? '-', '', ''),
        if (record.qCInspectionImages?.isNotEmpty ?? false) ...[
          const SizedBox(height: 10),
          const Text('Inspection Images:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: record.qCInspectionImages!.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final img = record.qCInspectionImages![i];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    img.imagePath ?? '',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                  ),
                );
              },
            ),
          ),
        ]
      ],
    );
  }
  Widget _buildStoresInspectionSection(MItem2 record) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDoubleRow('Status', record.qCStatus ?? '-', 'Remarks', record.inspectionRemarks ??  '-'),
        _buildDoubleRow('Quantity to Inspect', record.quantityToInspect?.toString() ?? '-', 'Approved Qty', record.qCApprovedQuantity?.toString() ?? '-'),
        if (record.qCInspectionImages?.isNotEmpty ?? false) ...[
          const SizedBox(height: 10),
          const Text('Inspection Images:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: record.qCInspectionImages!.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final img = record.qCInspectionImages![i];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    img.imagePath ?? '',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                  ),
                );
              },
            ),
          ),
        ]
      ],
    );
  }


  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return "-";
    try {
      return DateFormat('dd-MM-yyyy').format(DateTime.parse(rawDate));
    } catch (_) {
      return rawDate;
    }
  }

  bool _validateForm() {
    if (selectedApprovalStatus == null || selectedApprovalStatus == 'Select') {
      EasyLoading.showError('Please select QC Status');
      return false;
    }

    if (selectedApprovalStatus == 'Rejected' &&
        inspectionRemarksController.text.trim().isEmpty) {
      EasyLoading.showError('Remarks are required for Rejected status');
      return false;
    }

    if (inspectionRemarksController.text.trim().isEmpty) {
      EasyLoading.showError('Please enter inspection remarks');
      return false;
    }

    if (selectedImages.isEmpty) {
      EasyLoading.showError('Please upload at least one QC image');
      return false;
    }

    return true;
  }

}
