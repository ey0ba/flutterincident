import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkUtils {
  /// Checks if the device has an active network connection
  static Future<bool> hasNetworkConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
}
