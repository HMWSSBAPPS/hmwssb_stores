// ignore_for_file: avoid_annotating_with_dynamic

class AppUrls {
  static const String baseUrl =
  // 'https://erp.hyderabadwater.gov.in/SWCFeasibilityMobileAppAPI';
      'https://test3.hyderabadwater.gov.in/HMWSSBAPI';

  static const String getVersionUrl = '$baseUrl/GetLatestVersionNoForStoresApp';
  static const String getLoginOTPExternalUrl = '$baseUrl/SendLoginOTPExternal';
  // static const String getAllSuplierDetailsUrl = '$baseUrl/GetAllSuplierDetails';
  static const String getAllSuplierDetailsUrl = '$baseUrl/GetSupplierDetailsByWingUserID';
  static const String getPurchaseOrderListBySupplierUrl = '$baseUrl/GetPurchaseOrderListBySupplier';
  static const String getItemByPurchaseOrderNumberUrl = '$baseUrl/GetItemsByPurchaseOrderNumber';
  static const String getSaveIMSTPInspectionDetailsUrl = '$baseUrl/SaveIMSTPInspectionDetails';
  static const String getUserRoleDetailsUrl = '$baseUrl/GetUserRoles';
// static const String  Url= '$baseUrl/';
// static const String  Url= '$baseUrl/';
// static const String  Url= '$baseUrl/';
}
