

import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common_imports.dart';

class Utils {
  static DateTime get currentDateTime => DateTime.now();
  static TimeOfDay get currentTime => TimeOfDay.now();
  static final DateFormat dmyDateFrmt = DateFormat('dd-MM-yyyy');
  static final DateFormat ymdDateFrmtWithTime =
  DateFormat('yyyy-MM-dd HH:mm:ss');
  static final DateFormat ymdDateFrmt = DateFormat('yyyy-MM-dd');
  static final DateFormat dMonthNameYDateFrmt = DateFormat('dd-MMM-yyyy');

  // Date in DD-MM-YYYY Format
  static String getStringDateFrmtDMY({DateTime? dT}) {
    return dmyDateFrmt.format(dT ?? currentDateTime);
  }

  static Future<void> launchInBrowser(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      await EasyLoading.showInfo('Could not launch $url');
    }
  }

  static Future<void> launchURL(String url) async {
    if (url.isEmpty) {
      printDebug("URL is empty");
      EasyLoading.showInfo('URL is empty');
      return;
    }

    final Uri? uri = Uri.tryParse(url.trim());
    if (uri == null) {
      printDebug("Invalid URI: $url");
      EasyLoading.showInfo('Invalid URL: $url');
      return;
    }

    printDebug("Attempting to launch: $uri");
    bool canLaunch = await canLaunchUrl(uri);
    printDebug("Can launch: $canLaunch");

    if (canLaunch) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      printDebug("Failed to launch URL: $uri");
      EasyLoading.showError('Unable to open URL. Please try again later.');
    }
  }







  static Future<dynamic> openCamera({bool getBase64 = true}) async {
    try {
      // await Permission.camera.request();
      if (await Permission.camera.request().isGranted) {
        final XFile? image = await ImagePicker()
            .pickImage(source: ImageSource.camera, imageQuality: 40);
        if (getBase64 == true) {
          final Uint8List? base64Byte = await image?.readAsBytes();
          if (base64Byte != null) {
            String base64Encoded = base64Encode(base64Byte);
            return base64Encoded;
          }
          // final Uint8List imageBase64 = base64.decode(base64Encoded.toString());
          // print('base64 -> $base64Encoded');
          // print('base64 -> $imageBase64');
          return null;
        }
        return image;
      } else {
        EasyLoading.showToast('Allow Camera Permission Manually',
            toastPosition: EasyLoadingToastPosition.bottom);
        return null;
      }
    } on Exception catch (_) {
      return null;
    }
  }

  static Position? currentPosition;

  static Future<void> callLocApi() async {
    // Then, check for location permissions
    LocationPermission permission = await Geolocator.checkPermission();

    // If permission is denied, request it
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        await EasyLoading.showToast(
            'Location permissions are denied. Please allow the permissions.',
            toastPosition: EasyLoadingToastPosition.bottom);

        await Future<void>.delayed(
            const Duration(seconds: 3), () => Geolocator.openAppSettings());
      }
    }

    // Handle the case where permission is permanently denied
    if (permission == LocationPermission.deniedForever) {
      await EasyLoading.showToast(
          'Location permissions are permanently denied. Please enable it in app settings.',
          toastPosition: EasyLoadingToastPosition.bottom);
      await Future<void>.delayed(
          const Duration(seconds: 3), () => Geolocator.openAppSettings());
    }

    // If we have the permission, get the user's current location
    await _getCurrentPosition();
  }

  /// Helper function to get the current position of the device
  static Future<void> _getCurrentPosition() async {
    try {
      currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
      );
    } on Exception catch (e) {
      await EasyLoading.showError('Failed to get current position: $e');
    }
  }
}
