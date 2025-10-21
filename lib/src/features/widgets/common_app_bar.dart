import 'package:hmwssb_stores/common_imports.dart';

class CommonAppBar extends StatelessWidget {
  const CommonAppBar({required this.bodyWidget, super.key});
  final Widget bodyWidget;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: ThemeColors.primaryColor,
            title: CustomText(
                writtenText: Constants.appName,
                textStyle: ThemeTextStyle.style(color: ThemeColors.whiteColor)),
            iconTheme: const IconThemeData(color: ThemeColors.whiteColor)),
        body: bodyWidget);
  }
}
