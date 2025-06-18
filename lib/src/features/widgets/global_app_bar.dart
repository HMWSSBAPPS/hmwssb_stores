// lib/src/features/widgets/global_app_bar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common_imports.dart';
import '../login/provider/login_provider.dart';
import '../supplies/provider/supplier_provider.dart';

class GlobalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showRoleDropdown;
  final List<Widget>? actions;

  const GlobalAppBar({
    super.key,
    required this.title,
    this.showRoleDropdown = false,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);
    final supplierProvider = Provider.of<SupplierProvider>(context, listen: false);

    return AppBar(
      backgroundColor: ThemeColors.primaryColor,
      title: Row(
        children: [
          Expanded(
            child: CustomText(
              writtenText: title,
              textStyle: ThemeTextStyle.style(color: ThemeColors.whiteColor),
            ),
          ),
          if (showRoleDropdown && loginProvider.roles.isNotEmpty)
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                dropdownColor: Colors.white,
                iconEnabledColor: Colors.white,
                value: loginProvider.selectedRole?.roleCode,
                hint: const Icon(Icons.account_circle, color: Colors.white),
                items: loginProvider.roles.map((role) {
                  return DropdownMenuItem<String>(
                    value: role.roleCode,
                    child: Text(role.roleName ?? role.roleCode ?? '',
                        style: ThemeTextStyle.style(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (selectedRoleCode) {
                  final selected = loginProvider.roles.firstWhere(
                        (r) => r.roleCode == selectedRoleCode,
                    orElse: () => loginProvider.roles.first,
                  );

                  loginProvider.setSelectedRole(selected);
                  supplierProvider.getSupplierDetailsListApiCall(loginProvider);
                  NavigateRoutes.toRoleScreen(selectedRoleCode!);
                },
              ),
            ),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
