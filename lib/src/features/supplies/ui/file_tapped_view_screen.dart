import 'dart:io';
import 'package:hmwssb_stores/src/features/supplies/provider/supplier_provider.dart';
import '../../../../common_imports.dart';
import '../../../datamodel/items_by_purchase_order_number.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../../datamodel/save_imsqc_inspection_details.dart'; // For gallery and zoom

class FileViewTappedScreen extends StatefulWidget {
  const FileViewTappedScreen({required this.data, super.key});
  final ItemsByPurchaseOrderModel data;

  @override
  _FileViewTappedScreenState createState() => _FileViewTappedScreenState();
}

class _FileViewTappedScreenState extends State<FileViewTappedScreen> {
  late SupplierProvider supplierProvider;
  TextEditingController itemMakeController = TextEditingController();
  TextEditingController batchNoController = TextEditingController();
  TextEditingController inspectionRemarksController = TextEditingController();
  TextEditingController slaForQcController = TextEditingController();
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
  Future<void> _pickFile() async {
    final fileData = await Utils.pickFile();
    if (fileData != null) {
      setState(() {
        uploadedFileName = fileData['fileName'];
        uploadedFileBase64 = fileData['base64File'];
      });
    }
  }

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
    //_submitForm();
    Utils.callLocApi();
    slaForQcController.text = supplierProvider.itemByPurchaseOrderList.firstOrNull?.slaDate != null
        ? DateFormat('dd-MM-yyyy').format(DateTime.parse(supplierProvider.itemByPurchaseOrderList.firstOrNull!.slaDate!))
        : '';
  }

  Future<void> _submitForm() async {
    DateTime? inspectionDate;
    DateTime? manufactureDate;
    printDebug("Final Manufacture Date Sent: $selectedYearOfManufacturerAPI");

    // if (selectedYearOfManufacturerAPI == null || selectedYearOfManufacturerAPI!.isEmpty) {
    //   EasyLoading.showError('Manufacture Date is mandatory');
    //   return;
    // }
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

      if (inspectionDate != null) {
        if (inspectionDate.isBefore(manufactureDate)) {
          EasyLoading.showError('QC Inspection Date should be greater than or equal to the Manufacturing Date.');
          return;
        }
      }
    }


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

    SaveIMSQCInspectionDetailsModel postData = SaveIMSQCInspectionDetailsModel(
      purchaseOrderID: supplierProvider.selectedPurchaseOrderListBySupplies?.pkey,
      purchaseOrderLineItemID: supplierProvider.itemByPurchaseOrderList.firstOrNull?.lineItemPKey,
      quantity: supplierProvider.itemByPurchaseOrderList.firstOrNull?.quantity,
      unitType: supplierProvider.itemByPurchaseOrderList.firstOrNull?.units,
      gmReadiness: supplierProvider.itemByPurchaseOrderList.firstOrNull?.readyNessStatus,
      itemMake: itemMakeController.text,
      quantityToInspect: supplierProvider.itemByPurchaseOrderList.firstOrNull!.quantitytoInspect.toString(),
      batchNo: batchNoController.text,
      manufactureDate: selectedYearOfManufacturerAPI ?? '',
      inspectionDate: selectedDateOfQCInspectionAPI ?? '',
      inspectionRemarks: inspectionRemarksController.text,
      hSMNo: hsnNoFieldController.text,
      refPkey: supplierProvider.itemByPurchaseOrderList.firstOrNull?.refPkey,
      qCDoneBy: LocalStorages.getUserId(),
      qCStatus: selectedApprovalStatus ?? '',
      sLAQCChecks: supplierProvider.itemByPurchaseOrderList.firstOrNull?.slaDate,
      uploadDocName: uploadedFileName?.substring(0, 20) ?? '',
      uploadDocBase64: uploadedFileBase64 ?? '',
      qCInspectionImages: imagesList,
    );

    printDebug("Submitted Data: ${postData.toJson()}");
    await supplierProvider.postIMSQInspectDetailsApiCall(postData, supplierProvider);
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

  Future<void> _selectYearOfManufacture() async {
    DateTime now = DateTime.now();

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1990),
      lastDate: now,
      locale: const Locale('en', 'US'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            primaryColor: Colors.blueGrey,
            colorScheme: ColorScheme.light(primary: Colors.blueGrey),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedYearOfManufacturerDisplay = DateFormat("dd-MM-yyyy").format(picked); // UI format
        selectedYearOfManufacturerAPI = DateFormat("yyyy-MM-dd'T'00:00:00").format(picked); // API format
      });
      printDebug("Manufacture Date Selected: $selectedYearOfManufacturerAPI");
    }
  }

  Future<void> _selectYearOfQCInspection() async {
    DateTime currentDate = DateTime.now();

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,  // Default to today
      firstDate: DateTime(2000), // Allows past dates without restriction
      lastDate: DateTime(2100),  // Allows future dates
      locale: const Locale('en', 'US'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            primaryColor: Colors.blueGrey,
            colorScheme: ColorScheme.light(primary: Colors.blueGrey),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDateOfQCInspectionDisplay = DateFormat("dd-MM-yyyy").format(picked);
        selectedDateOfQCInspectionAPI = DateFormat("yyyy-MM-dd'T'00:00:00").format(picked);
      });

      // Validate QC Inspection Date against Manufacturing Date if available
      if (selectedYearOfManufacturerAPI != null) {
        DateTime manufactureDate = DateTime.parse(selectedYearOfManufacturerAPI!);

        if (picked.isBefore(manufactureDate)) {
          EasyLoading.showError('QC Inspection Date should be greater than or equal to the Manufacturing Date.');
        }
      }
    }
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
                    writtenText: "Item Make*",
                    textStyle: ThemeTextStyle.style()),
                const SizedBox(height: 10),
                CustomTextFormField(
                    controller: itemMakeController, focusNode: FocusNode()),
                const SizedBox(height: 20),
                CustomText(
                    writtenText: "Batch No.*",
                    textStyle: ThemeTextStyle.style()),
                const SizedBox(height: 10),
                CustomTextFormField(
                    controller: batchNoController, focusNode: FocusNode()),
                const SizedBox(height: 20),
                CustomText(
                    writtenText: "Date of Manufacture*",
                    textStyle: ThemeTextStyle.style()),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _selectYearOfManufacture,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade100,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedYearOfManufacturerDisplay ?? "Select Date",
                          style: TextStyle(
                            fontSize: 16,
                            color: selectedYearOfManufacturerDisplay == null
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                        const Icon(Icons.calendar_today,
                            color: Colors.blueGrey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                CustomText(
                    writtenText: "Date of QC Inspection*",
                    textStyle: ThemeTextStyle.style()),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _selectYearOfQCInspection,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade100,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedDateOfQCInspectionDisplay ?? "Select Date",
                          style: TextStyle(
                            fontSize: 16,
                            color: selectedDateOfQCInspectionDisplay == null
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                        const Icon(Icons.calendar_today,
                            color: Colors.blueGrey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
                    controller: inspectionRemarksController, focusNode: FocusNode()),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Upload Document (PDF/DOC)",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: uploadedFileName == null
                          ? InkWell(
                        onTap: _pickFile,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.upload_file, color: Colors.blue),
                            const SizedBox(width: 10),
                            Text(
                              "Choose File",
                              style: TextStyle(color: Colors.blue, fontSize: 16),
                            ),
                          ],
                        ),
                      )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              uploadedFileName!,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: _removeFile,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                CustomText(
                    writtenText: "HSN No.*",
                    textStyle: ThemeTextStyle.style()),
                const SizedBox(height: 10),
                CustomTextFormField(
                    controller: hsnNoFieldController, focusNode: FocusNode()),
                const SizedBox(height: 10),
                CustomText(
                    writtenText: "SLA for QC Checks",
                    textStyle: ThemeTextStyle.style()),
                const SizedBox(height: 10),
                CustomTextFormField(isReadOnly: true,
                    controller: slaForQcController, focusNode: FocusNode()),
                const SizedBox(height: 10),
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
                                inspectionRemarksController.text.trim().isNotEmpty),
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
