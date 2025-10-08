
import 'package:hmwssb_stores/src/features/supplies/provider/supplier_provider.dart';
import 'package:hmwssb_stores/src/features/supplies/ui/role_based_submit_screen/AdminSubmitScreen.dart';
import 'package:hmwssb_stores/src/features/supplies/ui/role_based_submit_screen/QcDgmSubmitScreen.dart';
import 'package:hmwssb_stores/src/features/supplies/ui/role_based_submit_screen/QcGmSubmitScreen.dart';
import 'package:hmwssb_stores/src/features/supplies/ui/role_based_submit_screen/QcManagerSubmitScreen.dart';
import 'package:hmwssb_stores/src/features/supplies/ui/role_based_submit_screen/StoreDgmSubmitScreen.dart';
import 'package:hmwssb_stores/src/features/supplies/ui/role_based_submit_screen/StoreGmSubmitScreen.dart';
import 'package:hmwssb_stores/src/features/supplies/ui/role_based_submit_screen/StoreManagerSubmitScreen.dart';

import '../../../../common_imports.dart';
import '../../../datamodel/items_by_purchase_order_number.dart';
import 'file_tapped_view_screen.dart';
import 'package:intl/intl.dart';



class PurchaseOrderDetailsScreen extends StatefulWidget {
  const PurchaseOrderDetailsScreen({super.key});

  @override
  State<PurchaseOrderDetailsScreen> createState() => _PurchaseOrderDetailsScreenState();
}

class _PurchaseOrderDetailsScreenState extends State<PurchaseOrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('🟢 Screen Loaded: PurchaseOrderDetailsScreen');
  }

  @override
  Widget build(BuildContext context) {
    return CommonAppBar(
      bodyWidget: Consumer<SupplierProvider>(
        builder: (BuildContext context, SupplierProvider provider, _) {
          if (provider.isLoading) {
            return const SizedBox.shrink();
          }

          final String? searchText = provider.ItemNameController.text.trim().toLowerCase();

          final List<ItemsByPurchaseOrderModel> filteredList = searchText!.isNotEmpty
              ? provider.itemByPurchaseOrderList.where((ItemsByPurchaseOrderModel element) {
            final String fileNumber = (element.itemName ?? '').toLowerCase();
            return fileNumber.contains(searchText);
          }).toList()
              : provider.itemByPurchaseOrderList;

          return Column(
            children: <Widget>[
              if (provider.itemByPurchaseOrderList.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomTextFormField(
                    controller: provider.ItemNameController,
                    focusNode: provider.ItemNameFocusNode,
                    labelText: 'Enter Item Name',
                    onChanged: (String val) {
                      provider.notifyToAllValues();
                    },
                    inputFormatters: <TextInputFormatter>[LengthLimitingTextInputFormatter(30)],
                    suffixIcon: searchText.isEmpty
                        ? const Icon(Icons.search)
                        : IconButton(
                      onPressed: () {
                        provider.ItemNameController.clear();
                        provider.notifyToAllValues();
                      },
                      icon: const Icon(Icons.cancel_outlined, color: ThemeColors.orangeColor),
                    ),
                  ),
                ),
              Expanded(
                child: filteredList.isEmpty
                    ? Center(
                  child: CustomText(
                    writtenText: Constants.noDataFound,
                    textStyle: ThemeTextStyle.style(),
                  ),
                )
                    : ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _customFileCard(
                      context: context,
                      data: filteredList[index],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _customFileCard({required BuildContext context, required ItemsByPurchaseOrderModel data}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
      child: InkWell(
        onTap: () async {
          final String roleCode = LocalStorages.getRoleCode();
          await NavigateRoutes.toRoleSubmitScreen(roleCode, data);
        },
        child: Container(
          decoration: BoxDecoration(
            color: ThemeColors.whiteColor,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: ThemeColors.primaryColor),
            boxShadow: const <BoxShadow>[
              BoxShadow(color: ThemeColors.primaryColor, offset: Offset(0.5, 0.5)),
              BoxShadow(color: ThemeColors.primaryColor, offset: Offset(-0.5, -0.5))
            ],
          ),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                    child: _customLabelBodyText(context: context, label: 'Agreement No.', body: data.agreementNo,),
                  )),
                  // Expanded(
                  //   child: Padding(
                  //     padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                  //     child: Row(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: <Widget>[
                  //         Expanded(
                  //           child: CustomText(
                  //             writtenText: 'Item Name',
                  //             textStyle: ThemeTextStyle.style(fontWeight: FontWeight.normal),
                  //           ),
                  //         ),
                  //         Expanded(
                  //           flex: 2,
                  //           child: CustomText(
                  //             writtenText: ': ${data.itemName ?? Constants.empty}',
                  //             textStyle: ThemeTextStyle.style(
                  //               color: ThemeColors.blueColor,
                  //               fontWeight: FontWeight.w600,
                  //             ),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  Container(
                    decoration: const BoxDecoration(
                      color: ThemeColors.primaryColor,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8.0),
                        topRight: Radius.circular(6.0),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                      child: CustomText(
                        writtenText: data.readyNessStatus ?? Constants.empty,
                        textStyle: ThemeTextStyle.style(color: ThemeColors.whiteColor),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: Column(
                  children: <Widget>[
                    8.ph,
                    _customLabelBodyText(context: context, label: 'Agreement Date', body: _formatDate(data.agreementDate)),
                    8.ph,
                    _customLabelBodyText(context: context, label: 'Item Name', body: data.itemName ?? Constants.empty),
                    8.ph,
                    _customLabelBodyText(context: context, label: 'Proposed Qty for Inspection', body: data.quantity.toString()),
                    8.ph,
                    _customLabelBodyText(context: context, label: 'Unit', body: data.units),
                    8.ph,
                    _customLabelBodyText(context: context, label: 'Unit Rate', body: data.unitsRate.toString()),
                    8.ph,
                    _customLabelBodyText(context: context, label: 'Qty to Inspect', body: data.quantitytoInspect.toString()),
                    8.ph,
                    _customLabelBodyText(context: context, label: 'SLA Date', body: _formatDate(data.slaDate)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _customLabelBodyText({required BuildContext context, required String label, required String? body}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        IntrinsicWidth(
          child: CustomText(
            writtenText: label,
            textStyle: ThemeTextStyle.style(fontWeight: FontWeight.normal),

          ),
        ),
        CustomText(
          writtenText: ' : ',
          textStyle: ThemeTextStyle.style(fontWeight: FontWeight.normal),
        ),
        Expanded(
          flex: 2,
          child: CustomText(
            writtenText: body ?? Constants.hypenSymbol,
            textStyle: ThemeTextStyle.style(
              color: ThemeColors.blueColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

String _formatDate(String? date) {
  if (date == null || date.isEmpty) return Constants.hypenSymbol;
  try {
    final DateTime parsedDate = DateTime.parse(date);
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  } catch (e) {
    return Constants.hypenSymbol;
  }
}

