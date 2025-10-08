// ignore_for_file: avoid_annotating_with_dynamic

class AppUrls {
  static const String baseUrl =
   'https://local.hyderabadwater.gov.in/HMWSSBAPI';
        //'https://test3.hyderabadwater.gov.in/HMWSSBAPI';

  static const String getVersionUrl = '$baseUrl/GetLatestVersionNoForStoresApp';
  static const String getLoginOTPExternalUrl = '$baseUrl/SendLoginOTPExternal';
  // static const String getAllSuplierDetailsUrl = '$baseUrl/GetAllSuplierDetails';
  static const String getAllSuplierDetailsUrl = '$baseUrl/GetSupplierDetailsByWingUserID';
  static const String getPurchaseOrderListBySupplierUrl = '$baseUrl/GetPurchaseOrderListBySupplierAndUserID';
  static const String getItemByPurchaseOrderNumberUrl = '$baseUrl/GetItemsByPurchaseOrderNumber';
  static const String getSaveIMSTPInspectionDetailsUrl = '$baseUrl/SaveIMSInspectionDetails';
  static const String getUserRoleDetailsUrl = '$baseUrl/GetUserRoles';
  static const String getTPInspectionDetailsUrl = '$baseUrl/GetTPInspectionDetails';
// static const String  Url= '$baseUrl/';
// static const String  Url= '$baseUrl/';
// static const String  Url= '$baseUrl/';
}
