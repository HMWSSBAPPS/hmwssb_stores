import 'package:hmwssb_stores/src/features/supplies/provider/supplier_provider.dart';
import '../../../../../common_imports.dart';
import '../../../login/login_index.dart';
import '../../../widgets/global_app_bar.dart';
import '../purchase_order_details_screen.dart';


class StoreDgmScreen extends StatefulWidget {
  const StoreDgmScreen({super.key});

  @override
  State<StoreDgmScreen> createState() => _StoreDgmScreenState();
}

class _StoreDgmScreenState extends State<StoreDgmScreen>{
  late SupplierProvider supplierProvider;
  late LoginProvider  loginProvider;
  String? selectedSupplier;
  String? selectedPurchaseOrder;
  bool isSubmitting = false; // Added loader flag
  bool _isInitialized = false;
  int? lastUserId;
  String? lastWingType;



  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      supplierProvider = Provider.of<SupplierProvider>(context, listen: false);
      loginProvider = Provider.of<LoginProvider>(context, listen: false);

      // Immediately load supplier data if possible
      _tryLoadSupplierData();

      // Listen for changes in loginProvider.loggedInUserData
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
    final loginData = loginProvider.loggedInUserData;
    if (loginData?.rolesInfo?.firstOrNull?.userID != lastUserId || loginData?.rolesInfo?.firstOrNull?.wingType != lastWingType) {
      lastUserId = loginData?.rolesInfo?.firstOrNull?.userID;
      lastWingType = loginData?.rolesInfo?.firstOrNull?.wingType;

      _tryLoadSupplierData();
    }
  }

  Future<void> _tryLoadSupplierData() async {
    final loginData = loginProvider.loggedInUserData;
    if (loginData?.rolesInfo?.firstOrNull?.userID != null && loginData?.rolesInfo?.firstOrNull?.wingType != null) {
      await supplierProvider.getSupplierDetailsListApiCall(loginProvider);
    }
  }




  @override
  Widget build(BuildContext context) {
    return Consumer<SupplierProvider>(
      builder: (BuildContext context, SupplierProvider provider, _) {
        return PopScope(
          canPop: false,
          child: GlobalAppBar(
            body: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Supplier Dropdown
                  CustomDropdown<String>(
                    labelStyle:
                    ThemeTextStyle.style(fontWeight: FontWeight.normal),
                    items: provider.supplierDetailsList
                        .map((supplier) => supplier.agencyName ?? '')
                        .toList(),
                    itemLabel: (String item) => item,
                    value: selectedSupplier,
                    hintText: 'Select Supplier',
                    onChanged: (String? newValue) async {
                      if (newValue != null) {
                        setState(() {
                          selectedSupplier = newValue;
                          selectedPurchaseOrder = null; // Reset purchase order selection
                        });

                        provider.selectedSupplierDetails =
                            provider.supplierDetailsList.firstWhere(
                                    (s) => s.agencyName == newValue);

                        await provider.getPurchaseOrderListBySuppliesApiCall();
                      }
                    },
                    showSearchBox: provider.supplierDetailsList.length > 6,
                    labelName: 'Supplier',
                  ),
                  const SizedBox(height: 16),

                  // Purchase Order Dropdown
                  CustomDropdown<String>(
                    labelStyle:
                    ThemeTextStyle.style(fontWeight: FontWeight.normal),
                    items: provider.purchaseOrderList
                        .map((order) => order.purchaseorderno ?? '')
                        .toList(),
                    itemLabel: (String item) => item,
                    value: selectedPurchaseOrder,
                    hintText: 'Select Purchase Order',
                    onChanged: selectedSupplier != null
                        ? (String? newValue) async {
                      if (newValue != null) {
                        setState(() {
                          selectedPurchaseOrder = newValue;
                        });

                        provider.selectedPurchaseOrderListBySupplies =
                            provider.purchaseOrderList.firstWhere(
                                    (order) => order.purchaseorderno == newValue);
                      }
                    }
                        : null, // Disable when no supplier is selected
                    showSearchBox: provider.purchaseOrderList.length > 6,
                    labelName: 'Purchase Order',
                  ),

                  const SizedBox(height: 24),

                  // Submit Button with Loader
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (selectedSupplier != null &&
                          selectedPurchaseOrder != null &&
                          !isSubmitting) // Prevent multiple clicks
                          ? () async {
                        setState(() {
                          isSubmitting = true;
                        });

                        await provider.getItemsByPurchaseOrderNumberApiCall(loginProvider);

                        setState(() {
                          isSubmitting = false;
                        });

                        NavigateRoutes.navigatePush(
                          context: context,
                          widget: PurchaseOrderDetailsScreen(),
                        );
                      }
                          : null, // Disable button if selections are incomplete
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
                        style: TextStyle(
                            color: Colors.white, fontSize: 16),
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

