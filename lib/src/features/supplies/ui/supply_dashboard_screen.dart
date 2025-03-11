import 'package:hmwssb_stores/src/features/supplies/provider/supplier_provider.dart';
import 'package:hmwssb_stores/src/features/supplies/ui/purchase_order_details_screen.dart';
import '../../../../common_imports.dart';

class SupplyDashboardScreen extends StatefulWidget {
  const SupplyDashboardScreen({super.key});

  @override
  State<SupplyDashboardScreen> createState() => _SupplyDashboardScreenState();
}

class _SupplyDashboardScreenState extends State<SupplyDashboardScreen> {
  late SupplierProvider supplierProvider;
  String? selectedSupplier;
  String? selectedPurchaseOrder;
  bool isSubmitting = false; // Added loader flag

  @override
  void initState() {
    super.initState();
    supplierProvider = Provider.of<SupplierProvider>(context, listen: false);
    supplierProvider.getSupplierDetailsListApiCall();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SupplierProvider>(
      builder: (BuildContext context, SupplierProvider provider, _) {
        return PopScope(
          canPop: false,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: ThemeColors.primaryColor,
              iconTheme: const IconThemeData(color: ThemeColors.whiteColor),
              title: FittedBox(
                child: CustomText(
                  writtenText: Constants.appFullName,
                  textStyle: ThemeTextStyle.style(
                    color: ThemeColors.whiteColor,
                  ),
                ),
              ),
            ),
            drawer: Drawer(
              width: context.width * .6,
              backgroundColor: ThemeColors.whiteColor,
              child: ListView(
                children: <Widget>[
                  Image.asset(
                    Assets.appLogo,
                    fit: BoxFit.fill,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: CustomText(
                      writtenText: LocalStorages.getMobileNumber(),
                      textStyle: ThemeTextStyle.style(),
                    ),
                  ),
                  const DottedDivider(),
                  ListTile(
                    leading: const CustomIcon(icon: Icons.logout),
                    title: CustomText(
                      writtenText: Constants.logOut,
                      textStyle: ThemeTextStyle.style(),
                    ),
                    onTap: () async {
                      await NavigateRoutes.navigateToLoginScreen(
                          isLogoutTap: true);
                    },
                  ),
                ],
              ),
            ),
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

                        await provider.getItemsByPurchaseOrderNumberApiCall();

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

