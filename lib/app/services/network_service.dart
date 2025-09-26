import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;


class NetworkService {
  static final Connectivity _connectivity = Connectivity();

  /// تشيك مرّة وحدة: هل فما إنترنت ولا لا؟
  static Future<bool> hasInternet() async {
    var result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// Listener: تسمع أي تغيير في حالة الشبكة (WiFi, Mobile, None)
  static Stream<List<ConnectivityResult>> get onNetworkChange {
    return _connectivity.onConnectivityChanged;
  }

  static Future<bool> checkRealInternet() async {
  // الخطوة 1: نشوف نوع الشبكة
  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) {
    return false; // ما فماش حتى network
  }

  // الخطوة 2: نتأكد من الإنترنت الحقيقي
  try {
    final response = await http.get(Uri.parse("https://www.google.com"))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      return true; // انترنت يخدم
    } else {
      return false;
    }
  } catch (_) {
    return false; // الشبكة مربوطة لكن ما فماش نت
  }
}
}
