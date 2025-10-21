import 'package:hmwssb_stores/src/datamodel/all_supply_details.dart';
import 'package:hmwssb_stores/src/datamodel/login_model.dart';
import 'package:hmwssb_stores/src/datamodel/purchase_order_list_by_supplies.dart';
import 'package:hmwssb_stores/src/features/login/login_index.dart';
import 'package:hmwssb_stores/src/features/supplies/provider/supplier_provider.dart';
import 'package:hmwssb_stores/src/features/supplies/ui/purchase_order_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hmwssb_stores/common_imports.dart';
import 'package:hmwssb_stores/src/features/widgets/global_app_bar.dart';

class SupplyDashboardScreen extends StatefulWidget {
  final bool showFullForm;
  const SupplyDashboardScreen({super.key, this.showFullForm = false});

  @override
  State<SupplyDashboardScreen> createState() => _SupplyDashboardScreenState();
}

class _SupplyDashboardScreenState extends State<SupplyDashboardScreen> {
  late SupplierProvider supplierProvider;
  late LoginProvider loginProvider;
  String? selectedSupplier;
  String? selectedPurchaseOrder;
  bool isSubmitting = false;
  bool _isInitialized = false;
  int? lastUserId;
  String? lastWingType;

  static const String kSelectedSupplierKey = 'selected_supplier';
  static const String kSelectedPurchaseOrderKey = 'selected_purchase_order';



  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      supplierProvider = Provider.of<SupplierProvider>(context, listen: false);
      loginProvider = Provider.of<LoginProvider>(context, listen: false);
      _tryLoadSupplierData();
      loginProvider.addListener(_onLoginDataChanged);
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    loginProvider.removeListener(_onLoginDataChanged);
    super.dispose();
  }

  void _onLoginDataChanged() {
    final MItem2? loginData = loginProvider.loggedInUserData;
    if (loginData?.rolesInfo?.firstOrNull?.userID != lastUserId || loginData?.rolesInfo?.firstOrNull?.wingType != lastWingType) {
      lastUserId = loginData?.rolesInfo?.firstOrNull?.userID;
      lastWingType = loginData?.rolesInfo?.firstOrNull?.wingType;
      _tryLoadSupplierData();
    }
  }

  Future<void> _tryLoadSupplierData() async {
    final MItem2? loginData = loginProvider.loggedInUserData;
    if (loginData?.rolesInfo?.firstOrNull?.userID != null && loginData?.rolesInfo?.firstOrNull?.wingType != null) {
      await supplierProvider.getSupplierDetailsListApiCall(loginProvider);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? savedSupplier = prefs.getString(kSelectedSupplierKey);
      final String? savedPO = prefs.getString(kSelectedPurchaseOrderKey);

      if (savedSupplier != null) {
        final AllSupplierDetailsListModel matchedSupplier = supplierProvider.supplierDetailsList.firstWhere(
              (AllSupplierDetailsListModel s) => s.agencyName == savedSupplier,
          orElse: () => supplierProvider.supplierDetailsList.first,
        );
        selectedSupplier = matchedSupplier.agencyName;
        supplierProvider.selectedSupplierDetails = matchedSupplier;
        //await supplierProvider.getPurchaseOrderListBySuppliesApiCall();

        if (savedPO != null) {
          final PurchaseOrderListMode matchedPO = supplierProvider.purchaseOrderList.firstWhere(
                (PurchaseOrderListMode po) => po.purchaseorderno == savedPO,
            orElse: () => supplierProvider.purchaseOrderList.first,
          );
          selectedPurchaseOrder = matchedPO.purchaseorderno;
          supplierProvider.selectedPurchaseOrderListBySupplies = matchedPO;
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<SupplierProvider>(
      builder: (BuildContext context, SupplierProvider provider, _) {
        // printDebug(LocalStorages.getFullUserData()!.mobileNo);
        return PopScope(
          canPop: false,
          child:  GlobalAppBar(

            body: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Supplier Dropdown
                  CustomDropdown<String>(
                    labelStyle: ThemeTextStyle.style(fontWeight: FontWeight.normal),
                    items: provider.supplierDetailsList
                        .map((AllSupplierDetailsListModel supplier) => supplier.agencyName ?? '')
                        .toList(),
                    itemLabel: (String item) => item,
                    value: selectedSupplier,
                    hintText: 'Select Supplier',
                    onChanged: (String? newValue) async {
                      if (newValue != null) {
                        final SharedPreferences prefs = await SharedPreferences.getInstance();

                        if (!mounted) {
                          return; // ✅ prevent setState if the widget is no longer in tree
                        }
                        setState(() {
                          selectedSupplier = newValue;
                          selectedPurchaseOrder = null;
                        });

                        prefs.setString(kSelectedSupplierKey, newValue);
                        prefs.remove(kSelectedPurchaseOrderKey);

                        supplierProvider.selectedSupplierDetails = provider
                            .supplierDetailsList
                            .firstWhere((AllSupplierDetailsListModel s) => s.agencyName == newValue);

                        await provider.getPurchaseOrderListBySuppliesApiCall();
                      }
                    },

                    showSearchBox: provider.supplierDetailsList.length > 6,
                    labelName: 'Supplier',
                  ),
                  const SizedBox(height: 16),

                  // Purchase Order Dropdown
                  CustomDropdown<String>(
                    labelStyle: ThemeTextStyle.style(fontWeight: FontWeight.normal),
                    items: provider.purchaseOrderList
                        .map((PurchaseOrderListMode order) => order.purchaseorderno ?? '')
                        .toList(),
                    itemLabel: (String item) => item,
                    value: selectedPurchaseOrder,
                    hintText: 'Select Purchase Order',
                    onChanged: selectedSupplier != null
                        ? (String? newValue) async {
                      if (newValue != null) {
                        final SharedPreferences prefs = await SharedPreferences.getInstance();
                        setState(() {
                          selectedPurchaseOrder = newValue;
                        });
                        prefs.setString(kSelectedPurchaseOrderKey, newValue);

                        provider.selectedPurchaseOrderListBySupplies =
                            provider.purchaseOrderList.firstWhere(
                                    (PurchaseOrderListMode order) => order.purchaseorderno == newValue);
                      }
                    }
                        : null,
                    showSearchBox: provider.purchaseOrderList.length > 6,
                    labelName: 'Purchase Order',
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (selectedSupplier != null &&
                          selectedPurchaseOrder != null &&
                          !isSubmitting)
                          ? () async {
                        setState(() {
                          isSubmitting = true;
                        });

                        await provider.getItemsByPurchaseOrderNumberApiCall(
                            loginProvider);

                        setState(() {
                          isSubmitting = false;
                        });

                        NavigateRoutes.navigatePush(
                          context: context,
                          widget: PurchaseOrderDetailsScreen(),
                        );
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColors.primaryColor,
                        disabledBackgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text(
                        'Submit',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
