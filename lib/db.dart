import 'package:okhi_flutter/okhi_flutter.dart';

class DB {
  static OkHiLocationManagerResponse? _response;

  static void saveAddress(OkHiLocationManagerResponse response) {
    _response = response;
  }

  static OkHiLocationManagerResponse? fetchAddress() {
    return _response;
  }
}
