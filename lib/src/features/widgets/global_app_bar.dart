import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common_imports.dart';
import '../login/provider/login_provider.dart';
import '../supplies/provider/supplier_provider.dart';

class GlobalAppBar extends StatefulWidget {
  final bool showRoleDropdown;
  final Widget body;

  const GlobalAppBar({
    super.key,
    required this.body,
    this.showRoleDropdown = true,
  });

  @override
  State<GlobalAppBar> createState() => _GlobalAppBarState();
}

class _GlobalAppBarState extends State<GlobalAppBar> {
  late LoginProvider loginProvider;
  late SupplierProvider supplierProvider;

  @override
  void initState() {
    super.initState();
    loginProvider = Provider.of<LoginProvider>(context, listen: false);
    supplierProvider = Provider.of<SupplierProvider>(context, listen: false);
    loginProvider.selectRole().then((_) => _loadInitialSupplier());
  }

  Future<void> _loadInitialSupplier() async {
    if (loginProvider.loginUserRolesMap.isNotEmpty) {
      await supplierProvider.getSupplierDetailsListApiCall(loginProvider);

      if (supplierProvider.supplierDetailsList.isNotEmpty) {
        supplierProvider.selectedSupplierDetails = supplierProvider.supplierDetailsList.first;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.body,
      drawer: Drawer(
        width: context.width * .6,
        backgroundColor: ThemeColors.whiteColor,
        child: ListView(
          children: <Widget>[
            Image.asset(Assets.appLogo, fit: BoxFit.fill),
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
                await NavigateRoutes.navigateToLoginScreen(isLogoutTap: true);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: ThemeColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            Expanded(
              child: CustomText(
                writtenText: Constants.appName,
                textStyle: ThemeTextStyle.style(color: ThemeColors.whiteColor),
              ),
            ),
            if (widget.showRoleDropdown && loginProvider.loginUserRolesMap.isNotEmpty)
              Consumer<LoginProvider>(
                builder: (context, loginProvider, _) {
                  final selectedValue = loginProvider.selectedRole['roleName'];
                  final roleNames = loginProvider.loginUserRolesMap
                      .map((role) => role['roleName'] ?? '')
                      .toSet()
                      .toList();

                  return DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      dropdownColor: Colors.black,
                      iconEnabledColor: Colors.white,
                      style: const TextStyle(color: Colors.white),
                      value: roleNames.contains(selectedValue) ? selectedValue : null,
                      items: roleNames.map((roleName) {
                        return DropdownMenuItem<String>(
                          value: roleName,
                          child: Text(roleName, style: ThemeTextStyle.style(fontSize: 14, color: Colors.white)),
                        );
                      }).toList(),
                        onChanged: (selectedRoleName) async {
                          final selectedMap = loginProvider.loginUserRolesMap.firstWhere(
                                (e) => e['roleName'] == selectedRoleName,
                            orElse: () => {},
                          );

                          await loginProvider.saveSelectedRoleLocally(selectedMap);

                          await supplierProvider.getSupplierDetailsListApiCall(loginProvider);

                          if (supplierProvider.supplierDetailsList.isNotEmpty) {
                            supplierProvider.selectedSupplierDetails = supplierProvider.supplierDetailsList.first;
                          }

                          setState(() {}); // Refresh the app bar

                          NavigateRoutes.toRoleScreen(selectedMap['roleCode'] ?? '');
                        }


                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
