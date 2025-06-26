  import 'package:hmwssb_stores/common_imports.dart';
import 'package:hmwssb_stores/src/datamodel/inspection_details_model.dart';
  import 'package:hmwssb_stores/src/features/login/login_index.dart';
  import '../../../core/network/network_index.dart';
  import '../../../datamodel/all_supply_details.dart';
  import '../../../datamodel/items_by_purchase_order_number.dart';
  import '../../../datamodel/purchase_order_list_by_supplies.dart';
  import '../../../datamodel/save_imsqc_inspection_details.dart';

  class SupplierProvider extends ChangeNotifier {
    bool isLoading = false;

    void isLoadData(bool isLoading) {
      this.isLoading = isLoading;
    }

    final TextEditingController ItemNameController = TextEditingController();
    final FocusNode ItemNameFocusNode = FocusNode();

    String getWingTypeFromLocalStorage() {
      final user = LocalStorages.getFullUserData();
      if (user != null && user.rolesInfo != null && user.rolesInfo!.isNotEmpty) {
        return user.rolesInfo!.first.wingType ?? "";
      }
      return "";
    }

    AllSupplierDetailsListModel? selectedSupplierDetails;
    List<AllSupplierDetailsListModel> supplierDetailsList = <AllSupplierDetailsListModel>[];
    String? persistedSelectedAgencyName;
    Future<void> autoSelectFirstSupplierOnly(LoginProvider loginProvider) async {
      await getSupplierDetailsListApiCall(loginProvider);

      if (supplierDetailsList.isNotEmpty) {
        selectedSupplierDetails = supplierDetailsList.first;
      }

      notifyToAllValues();
    }


    Future<void> getSupplierDetailsListApiCall(LoginProvider loginProvider) async {
      isLoadData(true);
      supplierDetailsList.clear();
      selectedSupplierDetails = null;

      final int userId = LocalStorages.getUserId();
      final String wingType = LocalStorages.getWingId(); // ✅ fixed method name

      if (userId == 0 || wingType.isEmpty) {
        EasyLoading.showError("User ID or Wing is missing.");
        isLoadData(false);
        notifyToAllValues();
        return;
      }

      final HTTPResponse<dynamic> response = await ApiCalling.callApi(
        isLoading: false,
        apiUrl: AppUrls.getAllSuplierDetailsUrl,
        apiFunType: APITypes.post,
        sendingData: {
          "UserID": userId,
          "Wing": wingType,
        },
      );

      if (response.statusCode == 200) {
        AllSupplierDetailsModel data = AllSupplierDetailsModel.fromJson(response.body);
        if (data.mItem1?.responseCode == '200') {
          supplierDetailsList = data.mItem2 ?? [];
        }
      } else {
        EasyLoading.showError("Failed to fetch supplier details");
      }

      isLoadData(false);
      notifyToAllValues();
    }

    PurchaseOrderListMode? selectedPurchaseOrderListBySupplies;
    List<PurchaseOrderListMode> purchaseOrderList = <PurchaseOrderListMode>[];

    Future<void> getPurchaseOrderListBySuppliesApiCall() async {
      isLoadData(true);
      purchaseOrderList.clear();
      selectedPurchaseOrderListBySupplies = null;
      final int userId = LocalStorages.getUserId();
      final String wingType = LocalStorages.getWingId(); // ✅ fixed method name

      if (userId == 0 || wingType.isEmpty) {
        EasyLoading.showError("User ID or Wing is missing.");
        isLoadData(false);
        notifyToAllValues();
        return;
      }
      final HTTPResponse<dynamic> response = await ApiCalling.callApi(
        isLoading: false,
        apiUrl: AppUrls.getPurchaseOrderListBySupplierUrl,
        apiFunType: APITypes.post,
        sendingData: {
          "SupplierID": selectedSupplierDetails?.supplierId,
          "UserID": userId,
          "Wing": wingType,
        },
      );

      if (response.statusCode == 200) {
        PurchaseOrderListBySuppliesModel data =
        PurchaseOrderListBySuppliesModel.fromJson(response.body);

        if (data.mItem1?.responseCode == '200') {
          purchaseOrderList = data.mItem2 ?? [];
        }
      }

      isLoadData(false);
      notifyToAllValues();
    }

    ItemsByPurchaseOrderModel? selectedItemByPurchaseOrder;
    List<ItemsByPurchaseOrderModel> itemByPurchaseOrderList = <ItemsByPurchaseOrderModel>[];

    Future<void> getItemsByPurchaseOrderNumberApiCall(LoginProvider loginProvider) async {
      isLoadData(true);
      itemByPurchaseOrderList.clear();
      selectedItemByPurchaseOrder = null;

      final String wingType = LocalStorages.getWingId(); // ✅ fixed method name


      final HTTPResponse<dynamic> response = await ApiCalling.callApi(
        isLoading: false,
        apiUrl: AppUrls.getItemByPurchaseOrderNumberUrl,
        apiFunType: APITypes.post,
        sendingData: {
          "POID": selectedPurchaseOrderListBySupplies?.pkey,
          "Wing": wingType,
        },
      );

      if (response.statusCode == 200) {
        ItemsByPurchaseOrderNumberModel data =
        ItemsByPurchaseOrderNumberModel.fromJson(response.body);

        if (data.mItem1?.responseCode == '200') {
          itemByPurchaseOrderList = data.mItem2 ?? [];
        }

        printDebug('Purchase Order List loaded: $itemByPurchaseOrderList');
      }

      isLoadData(false);
      notifyToAllValues();
    }

    Future<void> postIMSQInspectDetailsApiCall(
        SaveIMSQCInspectionDetailsModel postList, SupplierProvider supplierProvider) async {
      final HTTPResponse<dynamic> response = await ApiCalling.callApi(
        apiUrl: AppUrls.getSaveIMSTPInspectionDetailsUrl,
        apiFunType: APITypes.post,
        sendingData: postList.toJson(),
      );

      // print('API Response: ${response.body}');
      // print('API Request Body: ${postList.toJson()}');

      if (response.body is Map<String, dynamic>) {
        final responseBody = response.body as Map<String, dynamic>;
        final mItem1 = responseBody['m_Item1'] as Map<String, dynamic>?;

        if (mItem1 != null) {
          final responseCode = mItem1['ResponseCode'];
          final description = mItem1['Description'];

          if (responseCode == 300 && description != null) {
            EasyLoading.showError(description);
          } else if (description != null &&
              description.contains('Inspection Saved Successfully')) {
            EasyLoading.showSuccess('Inspection Saved Successfully');
            await Future.delayed(Duration(seconds: 2));
            NavigateRoutes.navigatePop();
            NavigateRoutes.navigatePop();
          } else {
            EasyLoading.showError(description ?? ConstantMessage.somethingWentWrongPleaseTryAgain);
          }
        }
      }

      notifyToAllValues();
    }

    InspectionDetailsModel? selectedInspectionDetails;
    List<MItem2> inspectionDetailRecords = <MItem2>[];
    List<MItem2> inspectionDetailRecordsAdditional = <MItem2>[]; // 👈 ADD THIS

    /// Fetch inspection details for a given PO
    Future<void> getTpInspectionDetailsApiCall(LoginProvider loginProvider) async {
      isLoadData(true);
      inspectionDetailRecords.clear();
      inspectionDetailRecordsAdditional.clear(); // 👈 CLEAR additional list as well
      selectedInspectionDetails = null;

      final int userId = LocalStorages.getUserId();
      final String wingType = LocalStorages.getWingId();

      if (userId == 0 || wingType.isEmpty) {
        EasyLoading.showError("User ID, Wing or POID is missing.");
        isLoadData(false);
        notifyToAllValues();
        return;
      }

      final HTTPResponse<dynamic> response = await ApiCalling.callApi(
        isLoading: false,
        apiUrl: AppUrls.getTPInspectionDetailsUrl,
        apiFunType: APITypes.post,
        sendingData: {
          "POID": selectedPurchaseOrderListBySupplies?.pkey,
          "UserID": userId,
          "Wing": wingType,
        },
      );

      if (response.statusCode == 200) {
        final model = InspectionDetailsModel.fromJson(response.body);

        if (model.mItem1?.responseCode == '200') {
          inspectionDetailRecords = model.mItem2 ?? [];
          inspectionDetailRecordsAdditional = model.mItem3 ?? []; // 👈 POPULATE ADDITIONAL RECORDS
        }
      } else {
        EasyLoading.showError("Failed to fetch inspection details");
      }

      isLoadData(false);
      notifyToAllValues();
    }



    void notifyToAllValues() => notifyListeners();
  }
