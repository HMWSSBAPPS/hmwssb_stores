import 'package:hmwssb_stores/common_imports.dart';
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
    //  notifyListeners();
  }

  final TextEditingController ItemNameController = TextEditingController();
  final FocusNode ItemNameFocusNode = FocusNode();

//********************************GET ALL SUPPLIER DETAILS API CALL**********************************//

  AllSupplierDetailsListModel? selectedSupplierDetails;
  List<AllSupplierDetailsListModel> supplierDetailsList =
  <AllSupplierDetailsListModel>[];
  Future<void> getSupplierDetailsListApiCall(LoginProvider loginProvider) async {
    isLoadData(true);
    supplierDetailsList.clear();
    selectedSupplierDetails = null;

    final int? userId = loginProvider.loggedInUserData?.userID;
    final String? wingType = loginProvider.loggedInUserData?.wingType;

    if (userId == null || wingType == null) {
      EasyLoading.showError("User ID or Wing is missing.");
      isLoadData(false);
      notifyToAllValues();
      return;
    }

    final HTTPResponse<dynamic> response = await ApiCalling.callApi(
      isLoading: false,
      apiUrl: AppUrls.getAllSuplierDetailsUrl,
      apiFunType: APITypes.post,
      sendingData: <String, dynamic>{
        "UserID": userId,
        "Wing": wingType,
      },
    );

    if (response.statusCode == 200) {
      AllSupplierDetailsModel data =
      AllSupplierDetailsModel.fromJson(response.body);
      if (data.mItem1?.responseCode == '200') {
        supplierDetailsList = data.mItem2 ?? [];
      }
    } else {
      EasyLoading.showError("Failed to fetch supplier details");
    }

    isLoadData(false);
    notifyToAllValues();
  }


//********************************GET PURCHASE ORDER LIST BY SUPPLIES API CALL**********************************//
  PurchaseOrderListMode? selectedPurchaseOrderListBySupplies;
  List<PurchaseOrderListMode> purchaseOrderList = <PurchaseOrderListMode>[];
  Future<void> getPurchaseOrderListBySuppliesApiCall() async {
    isLoadData(true);
    purchaseOrderList.clear();
    selectedPurchaseOrderListBySupplies = null;

    final HTTPResponse<dynamic> response = await ApiCalling.callApi(
      isLoading: false,
      apiUrl: AppUrls.getPurchaseOrderListBySupplierUrl,
      apiFunType: APITypes.post,
      sendingData: <String?, dynamic>{
        "SupplierID": selectedSupplierDetails?.supplierId,
      },
    );

    if (response.statusCode == 200) {
      printDebug("response ${response.statusCode} ${response.body}");

      PurchaseOrderListBySuppliesModel data =
      PurchaseOrderListBySuppliesModel.fromJson(response.body);

      if (data.mItem1?.responseCode == '200') {
        if (data.mItem2?.isNotEmpty ?? false) {
          purchaseOrderList = data.mItem2 ?? [];
        }
      }
    }
    isLoadData(false);
    notifyToAllValues();
  }

  //********************************GET ITEMS BY PURCHASE ORDER NUMBER API CALL**********************************//
  ItemsByPurchaseOrderModel? selectedItemByPurchaseOrder;
  List<ItemsByPurchaseOrderModel> itemByPurchaseOrderList =
  <ItemsByPurchaseOrderModel>[];
  Future<void> getItemsByPurchaseOrderNumberApiCall(LoginProvider loginProvider) async {
    isLoadData(true);
    itemByPurchaseOrderList.clear();
    selectedItemByPurchaseOrder = null;
    final String? wingType = loginProvider.loggedInUserData?.wingType;
    final HTTPResponse<dynamic> response = await ApiCalling.callApi(
      isLoading: false,
      apiUrl: AppUrls.getItemByPurchaseOrderNumberUrl,
      apiFunType: APITypes.post,
      sendingData: <String?, dynamic>{
        "POID": selectedPurchaseOrderListBySupplies?.pkey,
        "Wing": wingType
      },
    );
    if (response.statusCode == 200) {
      printDebug("response ${response.statusCode} ${response.body}");

      ItemsByPurchaseOrderNumberModel data =
      ItemsByPurchaseOrderNumberModel.fromJson(response.body);

      if (data.mItem1?.responseCode == '200') {
        if (data.mItem2?.isNotEmpty ?? false) {
          itemByPurchaseOrderList = data.mItem2 ?? [];
        }
      }

      printDebug('Purchase Order List loaded: $itemByPurchaseOrderList');
    }
    isLoadData(false);
    notifyToAllValues();
  }

  //********************************GET SAVE IMSQ INSPECT DETAILS API CALL**********************************//
  Future<void> postIMSQInspectDetailsApiCall(
      SaveIMSQCInspectionDetailsModel postList, SupplierProvider supplierProvider) async {
    final HTTPResponse<dynamic> response = await ApiCalling.callApi(
      apiUrl: AppUrls.getSaveIMSTPInspectionDetailsUrl,
      apiFunType: APITypes.post,
      sendingData: postList.toJson(),
    );

    print('API Response: ${response.body}');
    print('API Response: ${postList.toJson()}');
    print('Response Type: ${response.body.runtimeType}');

    if (response.body is Map<String, dynamic>) {
      final responseBody = response.body as Map<String, dynamic>;
      final mItem1 = responseBody['m_Item1'] as Map<String, dynamic>?;

      if (mItem1 != null) {
        final responseCode = mItem1['ResponseCode'];
        final description = mItem1['Description'];

        if (responseCode == 300 && description != null) {
          EasyLoading.showError(description); // Display the error message
        } else if (description != null &&
            description.contains('QC Inspection Saved Successfully')) {
          EasyLoading.showSuccess('QC Inspection Saved Successfully');
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



  void notifyToAllValues() => notifyListeners();
}
