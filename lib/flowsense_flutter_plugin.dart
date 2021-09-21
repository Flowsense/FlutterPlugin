import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';

typedef void FlowsenseReceivedNotif(dynamic notif);
typedef void FlowsenseClickedNotif(dynamic notif);
typedef void FlowsensePushToken(dynamic pushToken);
typedef void FlowsensePushPermission(dynamic pushPermission);

class FlowsenseFlutterPlugin {

  static FlowsenseFlutterPlugin shared = new FlowsenseFlutterPlugin();

  MethodChannel _channel = const MethodChannel('FlowsenseSDK');

  FlowsenseReceivedNotif _receivedNotification;
  FlowsenseClickedNotif _clickedNotification;
  FlowsensePushToken _pushToken;
  FlowsensePushPermission _pushPermission;

  FlowsenseFlutterPlugin() {
    this._channel.setMethodCallHandler(_handleMethod);
    if (Platform.isAndroid) {
      _channel.invokeMethod('FlowsenseSDK#startFlowsense', null);
    }
  }

  Future<void> startFlowsenseService(String authToken) async {
    await _channel.invokeMethod(
        'FlowsenseSDK#startFlowsenseService', {'authToken': authToken});
  }

  Future<void> updatePartnerUserId(String userID) async {
    await _channel.invokeMethod(
        'FlowsenseSDK#updatePartnerUserId', {'userID': userID});
  }

  Future<void> updatePhoneNumber(String phoneNumber) async {
    await _channel.invokeMethod(
        'FlowsenseSDK#updatePhoneNumber', {'phoneNumber': phoneNumber});
  }

  Future<void> updateEmail(String email) async {
    await _channel.invokeMethod(
        'FlowsenseSDK#updateEmail', {'email': email});
  }

  Future<void> pushNotificationsEnabled(bool enabled) async {
    await _channel.invokeMethod(
        'FlowsenseSDK#pushNotificationsEnabled', {'enabled': enabled});
  }

  Future<void> smsEnabled(bool enabled) async {
    await _channel.invokeMethod(
        'FlowsenseSDK#smsEnabled', {'enabled': enabled});
  }

  Future<void> emailEnabled(bool enabled) async {
    await _channel.invokeMethod(
        'FlowsenseSDK#emailEnabled', {'enabled': enabled});
  }

  Future<void> createNotificationChannel(String channelName) async {
    await _channel.invokeMethod(
        'FlowsenseSDK#createNotificationChannel', {'channelName': channelName});
  }

  Future<void> setKeyValue(Map<String, dynamic> keyValues) async {
    Map<String, dynamic> keyValueMap = new Map<String, dynamic>();
    keyValues.forEach((k, v) {
      var key = k;
      var value = v;
      if (v is DateTime) {
        value = v.millisecondsSinceEpoch;
        key = "FSDate_" + key;
      } else if (v is bool && Platform.isIOS) {
        key = "FSBool_" + key;
      }
      keyValueMap[key] = value;
    });
    await _channel.invokeMethod(
        'FlowsenseSDK#setKeyValue', {"keyValues": keyValueMap});
  }

  Future<void> commitChanges() async {
    await _channel.invokeMethod(
        'FlowsenseSDK#commitChanges', null);
  }

  Future<void> sendMessageToFlowsense([ dynamic notification ]) async {
    await _channel.invokeMethod(
        'FlowsenseSDK#sendMessageToFlowsense', notification);
  }

  Future<void> inAppEvent(String eventName, Map<String, dynamic> eventMap) async {
    Map<String, dynamic> eMap = new Map<String, dynamic>();
    eventMap.forEach((k, v) {
      var key = k;
      var value = v;
      if (v is DateTime) {
        value = v.millisecondsSinceEpoch;
        key = "FSDate_" + key;
      } else if (v is bool && Platform.isIOS) {
        key = "FSBool_" + key;
      }
      eMap[key] = value;
    });
    await _channel.invokeMethod('FlowsenseSDK#inAppEvent',
      {'eventName': eventName, 'eventMap': eMap});
  }

  void requestPushToken() {
    _channel.invokeMethod("FlowsenseSDK#requestPushToken");
  }

  void requestAlwaysAuthorization() {
    _channel.invokeMethod("FlowsenseSDK#requestAlwaysAuthorization");
  }
  
  void startMonitoringLocation() {
    _channel.invokeMethod("FlowsenseSDK#startMonitoringLocation");
  }

  void setPushReceivedCallback(FlowsenseReceivedNotif handler) {
    _receivedNotification = handler;
  }

  void setPushClickedCallback(FlowsenseClickedNotif handler) {
    _clickedNotification = handler;
    // _channel.invokeMethod("OneSignal#didSetNotificationOpenedHandler");
  }

  void setPushTokenCallback(FlowsensePushToken handler) {
    _pushToken = handler;
  }

  void setPushPermissionCallback(FlowsensePushPermission handler) {
    _pushPermission = handler;
  }

  Future<Null> _handleMethod(MethodCall call) async {
    if (call.method == 'FlowsenseSDK#receivedNotification' &&
        this._receivedNotification != null) {
      this._receivedNotification(call.arguments);
    } else if (call.method == 'FlowsenseSDK#clickedNotification' &&
        this._clickedNotification != null) {
      this._clickedNotification(call.arguments);
    } else if (call.method == 'FlowsenseSDK#pushToken' &&
        this._pushToken != null) {
          this._pushToken(call.arguments);
    } else if (call.method == 'FlowsenseSDK#pushPermission' &&
        this._pushPermission != null) {
          this._pushPermission(call.arguments);
    }

    return null;
  }

}
