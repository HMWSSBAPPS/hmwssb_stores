import 'package:hmwssb_stores/common_imports.dart';
import 'package:hmwssb_stores/src/features/login/login_index.dart';
import 'package:hmwssb_stores/src/features/supplies/provider/supplier_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);
  await LocalStorages.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
    return MultiProvider(
        // ignore: always_specify_types
          providers: [
            ChangeNotifierProvider<LoginProvider>(create: (_) => LoginProvider()),
            ChangeNotifierProvider<SupplierProvider>(
                create: (_) => SupplierProvider()),
            // ChangeNotifierProvider<FeasibilityProvider>(
            //     create: (_) => FeasibilityProvider()),
          ],
          child: SafeArea(
              child: MaterialApp(
                  debugShowCheckedModeBanner: false,
                  navigatorKey: NavigateRoutes.navigatorKey,
                  theme: ThemeData(
                      scaffoldBackgroundColor: ThemeColors.whiteColor,
                      popupMenuTheme: const PopupMenuThemeData(
                          color: ThemeColors.whiteColor,
                          textStyle: TextStyle(color: ThemeColors.blackColor)),
                      fontFamily: 'RadioCanada'),
                  builder: EasyLoading.init(
                    builder: (BuildContext context, Widget? child) {
                      return MediaQuery(
                        data: MediaQuery.of(context)
                            .copyWith(textScaler: const TextScaler.linear(1.0)),
                        child: child!,
                      );
                    },
                  ),
                  home: const SplashScreen()))
    );
  }
}
