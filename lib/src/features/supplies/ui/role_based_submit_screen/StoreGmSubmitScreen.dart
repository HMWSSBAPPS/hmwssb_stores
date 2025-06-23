import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:hmwssb_stores/src/features/login/login_index.dart';
import 'package:hmwssb_stores/src/features/supplies/provider/supplier_provider.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../../../../common_imports.dart';
import '../../../../datamodel/items_by_purchase_order_number.dart';
import '../../../../datamodel/save_imsqc_inspection_details.dart';


class StoreGmSubmitScreen extends StatefulWidget {
  const StoreGmSubmitScreen({required this.data, super.key});
  final ItemsByPurchaseOrderModel data;

  @override
  _StoreGmSubmitScreenState createState() => _StoreGmSubmitScreenState();
}

class _StoreGmSubmitScreenState extends State<StoreGmSubmitScreen> {
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

  // List to store selected images
  List<XFile> selectedImages = [];
  int? _currentImageIndex; // To track the selected image for full-screen view
  // Future<void> _pickFile() async {
  //   final result = await FilePicker.platform.pickFiles(
  //     type: FileType.custom,
  //     allowedExtensions: ['pdf', 'doc', 'docx'],
  //   );
  //
  //   if (result != null && result.files.single.path != null) {
  //     final file = File(result.files.single.path!);
  //     final fileSizeInBytes = await file.length();
  //
  //     if (fileSizeInBytes > 1024 * 1024) {
  //       // 1MB = 1024 * 1024 bytes
  //       EasyLoading.showError('File size must be under 1MB.');
  //       return;
  //     }
  //
  //     final fileExtension = result.files.single.extension?.toLowerCase();
  //     const allowedExtensions = ['pdf', 'doc', 'docx'];
  //
  //     if (!allowedExtensions.contains(fileExtension)) {
  //       EasyLoading.showError('Only PDF, DOC, and DOCX files are allowed.');
  //       return;
  //     }
  //
  //     final fileBytes = await file.readAsBytes();
  //     setState(() {
  //       uploadedFileName = result.files.single.name;
  //       uploadedFileBase64 = base64Encode(fileBytes);
  //     });
  //
  //     EasyLoading.showSuccess('File uploaded successfully!');
  //   }
  // }

  void _removeFile() {
    setState(() {
      uploadedFileName = null;
      uploadedFileBase64 = null;
    });
  }

  @override
  void initState() {
    super.initState();
    supplierProvider = Provider.of(context, listen: false);
    loginProvider = Provider.of(context, listen: false);
    Utils.callLocApi();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectedItem = widget.data; // ✅ Use passed-in data directly

      slaForQcController.text = selectedItem.slaDate != null
          ? DateFormat('dd-MM-yyyy')
          .format(DateTime.parse(selectedItem.slaDate!))
          : '';

      proposedQuantityController.text = selectedItem.quantity?.toString() ?? '';
      quantityToInspectController.text =
          selectedItem.quantitytoInspect?.toString() ?? '';
    });
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

  // Image picker, calendar selection, etc., remain the same
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



  // Show full-screen zoomable image
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
            backgroundDecoration: BoxDecoration(
              color: Colors.black,
            ),
            pageController:
            PageController(initialPage: _currentImageIndex ?? 0),
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
    return CommonAppBar(
      bodyWidget: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                    writtenText: "Proposed Quantity",
                    textStyle: ThemeTextStyle.style()),
                const SizedBox(height: 10),
                CustomTextFormField(
                    isReadOnly: true,
                    controller: proposedQuantityController,
                    focusNode: FocusNode()),
                const SizedBox(height: 10),
                CustomText(
                    writtenText: "Quantity To Inspect",
                    textStyle: ThemeTextStyle.style()),
                const SizedBox(height: 10),
                CustomTextFormField(
                    isReadOnly: true,
                    controller: quantityToInspectController,
                    focusNode: FocusNode()),
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
                CustomText(
                    writtenText: "Inspection Remarks",
                    textStyle: ThemeTextStyle.style()),
                const SizedBox(height: 10),
                CustomTextFormField(
                    controller: inspectionRemarksController,
                    focusNode: FocusNode()),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Upload Image Section
                    CustomText(
                      writtenText: "Upload QC Reports and Photos",
                      textStyle: ThemeTextStyle.style(),
                    ),
                    const SizedBox(height: 10),

                    // Image Upload Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: selectedImages.length +
                          (selectedImages.length < 5 ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == selectedImages.length) {
                          // Image Upload Button
                          return GestureDetector(
                            onTap: _captureImage,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.add_a_photo,
                                  size: 40, color: Colors.blue),
                            ),
                          );
                        }
                        // Display Selected Images
                        return GestureDetector(
                          onTap: () => _openFullScreenImage(index),
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: FileImage(
                                        File(selectedImages[index].path)),
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
                                  child: Icon(Icons.remove_circle,
                                      color: Colors.red, size: 24),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20), // Space before Save button

                    // Save Button
                    Center(
                      child: SubmitButtonFillWidget(
                        onTap: _submitForm,
                        text: 'Save',
                        btnColor: ThemeColors.primaryColor,
                        isEnabled: uploadedFileName != null &&
                            selectedImages.isNotEmpty &&
                            (selectedApprovalStatus != "Rejected" ||
                                inspectionRemarksController.text
                                    .trim()
                                    .isNotEmpty),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
