import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import '../../../../../common_imports.dart';
import '../../../../datamodel/items_by_purchase_order_number.dart';
import '../../../../datamodel/purchase_order_list_by_supplies.dart';
import '../../../../datamodel/save_imsqc_inspection_details.dart';
import '../../../login/login_index.dart';
import '../../provider/supplier_provider.dart';

class StoreManagerSubmitScreen extends StatefulWidget {
  const StoreManagerSubmitScreen({required this.data, super.key});
  final ItemsByPurchaseOrderModel data;

  @override
  State<StoreManagerSubmitScreen> createState() => _StoreManagerSubmitScreenState();
}

class _StoreManagerSubmitScreenState extends State<StoreManagerSubmitScreen> {
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

  Future<void> _captureImage() async {
    if (selectedImages.length >= 5) {
      EasyLoading.showInfo('You can upload a maximum of 5 images.');
      return;
    }

    final image = await Utils.openCamera(getBase64: false);
    if (image != null && image is XFile) {
      setState(() {
        selectedImages.add(image);
      });
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
            builder: (context, idx) {
              return PhotoViewGalleryPageOptions(
                imageProvider: FileImage(File(selectedImages[idx].path)),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered,
              );
            },
            pageController: PageController(initialPage: _currentImageIndex ?? 0),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            onPageChanged: (index) => setState(() => _currentImageIndex = index),
          ),
        );
      },
    );
  }

  Future<void> _submitForm() async {
    printDebug("Final Manufacture Date Sent: $selectedYearOfManufacturerAPI");

    // if (selectedYearOfManufacturerAPI == null || selectedYearOfManufacturerAPI!.isEmpty) {
    //   EasyLoading.showError('Manufacture Date is mandatory');
    //   return;
    // }



    if (selectedApprovalStatus == "Rejected" &&
        inspectionRemarksController.text.trim().isEmpty) {
      EasyLoading.showError('Inspection Remarks are required for rejected QC.');
      return;
    }

    List<QCInspectionImages> imagesList = selectedImages.map((image) {
      return QCInspectionImages(
        appName: "STORESAPP",
        imageType: selectedImages.indexOf(image) + 1,
        imageName: image.name,
        imageLatitude: Utils.currentPosition?.latitude.toString() ?? "0.0",
        imageLongitude: Utils.currentPosition?.longitude.toString() ?? "0.0",
        base64Image: base64Encode(File(image.path).readAsBytesSync()),
      );
    }).toList();
    final String approvedQtyText = approvedQuantityController.text.trim();
    final double? approvedQuantity = double.tryParse(approvedQtyText);
    final double? quantity =
    widget.data.quantity?.toDouble(); // ✅ Instead of provider
    final String wingType = LocalStorages.getWingId();
    SaveIMSQCInspectionDetailsModel postData = SaveIMSQCInspectionDetailsModel(
      purchaseOrderID:
      supplierProvider.selectedPurchaseOrderListBySupplies?.pkey,
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
    printDebug(
        'Encoded base64 starts with: ${uploadedFileBase64?.substring(0, 30)}');

    printDebug("Submitted Data: ${postData.toJson()}");
    await supplierProvider.postIMSQInspectDetailsApiCall(
        postData, supplierProvider);
  }

  bool _validateForm() {
    if (selectedApprovalStatus == null || selectedApprovalStatus == 'Select') {
      EasyLoading.showError('Please select QC Status');
      return false;
    }

    if (selectedApprovalStatus == 'Rejected' && inspectionRemarksController.text.trim().isEmpty) {
      EasyLoading.showError('Remarks are required for Rejected status');
      return false;
    }

    if (selectedImages.isEmpty) {
      EasyLoading.showError('Please upload at least one image');
      return false;
    }

    return true;
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return "-";
    try {
      return DateFormat('dd-MM-yyyy').format(DateTime.parse(rawDate));
    } catch (_) {
      return rawDate;
    }
  }

  Widget _buildRow(String label, String value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
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
    print("Line Item RefPkey: ${data.refPkey}");
    print("Inspection Records Total: ${supplierProvider.inspectionDetailRecords.length}");
    supplierProvider.inspectionDetailRecords.forEach((r) {
      print("Inspection RefPKey: ${r.refPKey}, PO Line Item ID: ${r.purchaseOrderLineItemID}");
    });

    // Filter inspection records
    final recs = supplierProvider.inspectionDetailRecords.where((r) =>
    r.refPKey != null && data.refPkey != null && r.refPKey == data.refPkey
    ).toList();
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Purchase Order Details', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _buildDoubleRow('Agreement No', data.agreementNo ?? '-', 'Agreement Date', _formatDate(data.agreementDate)),
            _buildDoubleRow('Item Name', data.itemName ?? '-', 'Proposed Quantity For Inspection', '${data.quantity ?? '-'}'),
            _buildDoubleRow('Units', data.units ?? '-', 'Units Rate', data.unitsRate?.toString() ?? '-'),
            _buildDoubleRow('Quantity to Inspect', '${data.quantitytoInspect ?? '-'}', 'SLA Date', _formatDate(data.slaDate)),
            _buildDoubleRow('Readiness Status', data.readyNessStatus ?? '-', '', ''),
            const SizedBox(height: 20),

            if (recs.isNotEmpty) ...[
              Text('Third Party Inspection Details', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recs.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (ctx, index) {
                  final record = recs[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDoubleRow('Item Make', record.itemMake ?? '-', 'Batch No', record.batchNo ?? '-'),
                      _buildDoubleRow('Readiness Status', record.gmReadiness ?? '-', 'Manufacture Date', _formatDate(record.manufactureDate)),
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
                      ],
                    ],
                  );
                },
              ),
            ] else ...[
              const Text('No inspection data available for this line item', style: TextStyle(color: Colors.grey)),
            ],
          ],
        ),
      ),
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
                  items: const ['Select', 'Approved', 'Rejected'],
                  itemLabel: (item) => item,
                  value: selectedApprovalStatus ?? 'Select',
                  hintText: 'QC Status',
                  labelName: 'QC Status*',
                  onChanged: (newValue) {
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
                CustomText(writtenText: "Upload QC Reports and Photos", textStyle: ThemeTextStyle.style()),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
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
                              child: const Icon(Icons.remove_circle, color: Colors.red, size: 24),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
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
}
