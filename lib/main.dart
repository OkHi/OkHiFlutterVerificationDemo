import 'package:flutter/material.dart';
import 'package:okhi_flutter/models/okhi_usage_type.dart';
import 'package:okhi_flutter/okhi_flutter.dart';
import './db.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _launch = false;
  List<UsageType> _usageTypes = [UsageType.addressBook];
  String? _locationId;

  @override
  void initState() {
    super.initState();
    final config = OkHiAppConfiguration(
      branchId: "", // your branch ID
      clientKey: "", // your client key
      env: OkHiEnv.sandbox,
      notification: OkHiAndroidNotification(
        title: "Verification in progress",
        text: "Verifying your address",
        channelId: "okhi",
        channelName: "OkHi",
        channelDescription: "Verification alerts",
      ),
    );
    OkHi.initialize(config);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('OkHi Flutter Demo'),
        ),
        body: _renderBody(),
      ),
    );
  }

  _renderBody() {
    if (_launch) {
      return OkHiLocationManager(
        user: _createOkHiUser(),
        onCloseRequest: _handleOnClose,
        onError: _handleOnError,
        onSucess: _handleOnSuccess,
        configuration: OkHiLocationManagerConfiguration(
          locationId: _locationId,
          usageTypes: _usageTypes,
        ),
      );
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: _handleCreateAnAddressPress,
            child: const Text('Create an address'),
          ),
          ElevatedButton(
            onPressed: _handleVerifySavedAddressPress,
            child: const Text('Verify saved address'),
          ),
        ],
      ),
    );
  }

  _handleVerifySavedAddressPress() {
    final response = DB.fetchAddress();
    if (response != null) {
      _locationId = response.location.id;
      _usageTypes = [UsageType.digitalVerification];
      setState(() {
        _launch = true;
      });
    }
  }

  _handleCreateAnAddressPress() {
    setState(() {
      _launch = true;
    });
  }

  OkHiUser _createOkHiUser() {
    return OkHiUser(
      phone: "+2547..",
      firstName: "John",
      lastName: "Doe",
      appUserId: "abcd1234",
      email: "john@okhi.co",
    );
  }

  _handleOnSuccess(OkHiLocationManagerResponse response) async {
    setState(() {
      _launch = false;
    });
    final String locationId = await response.startVerification(null);
    print("started verification for: $locationId");
    DB.saveAddress(response);
  }

  _handleOnError(OkHiException exception) {
    print(exception.code);
    print(exception.message);
  }

  _handleOnClose() {
    setState(() {
      _launch = false;
    });
  }
}
