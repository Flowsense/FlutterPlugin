# Flowsense Flutter Plugin

Installing the Flowsense SDK is fairly simple. Carefully follow the next steps and start enjoying more precise engagement for your app.

## Important

Flowsense is a service that requires a set of authentication tokens to work. Please [contact](contato@flowsense.com.br) sales before attempting to install the plugin.

## Requirements

- Android version 16 or higher.
- Compatibility with the following dependency versions:

```
api 'com.google.code.gson:gson:2.8.2'
api 'io.sentry:sentry-android:1.7.2'
api 'com.google.android.gms:play-services-location:16.0.0'
api 'com.google.firebase:firebase-core:16.0.9'
api 'com.google.firebase:firebase-messaging:17.6.0'
api 'com.amazonaws:*:2.11.0'
```

## Starting the plugin

Flowsense provides a token for each platform. Start the plugin passing the platform specific token:

```
if (Platform.isIOS) {
    FlowsenseFlutterPlugin.shared.startFlowsenseService("your_ios_token");
} else {
    FlowsenseFlutterPlugin.shared.startFlowsenseService("your_android_token");
}
```

## Geolocation

If using geolocation, include the location authorization request in runtime:

```
// Request permission
FlowsenseFlutterPlugin.shared.requestAlwaysAuthorization();

// Start location tracking
FlowsenseFlutterPlugin.shared.startMonitoringLocation();
```

> On iOS you must include three keys to your Info.plist in order to show the location permission message:
> 1. Privacy - Location Always and When In Use Usage Description
> 2. Privacy - Location Always Usage Description
> 3. Privacy - Location When In Use Usage Description
> 
> Each of these keys must contain the message you wish to present to the user when location is requested.

## User identifier

You can pass an anonimized user identifier to Flowsense by:

```
FlowsenseFlutterPlugin.shared.updatePartnerUserId("your_anonimized_user_info");
```

## Enrich user data

You can pass a set of key-values to Flowsense in order to enrich the user information:

```
FlowsenseFlutterPlugin.shared.setKeyValue({"Last Purchase ID": "AIFTS-DF86F"});
FlowsenseFlutterPlugin.shared.setKeyValue({"Last Purchase Value": 63});
FlowsenseFlutterPlugin.shared.setKeyValue({"Registered User": false});
FlowsenseFlutterPlugin.shared.setKeyValue({"Last Purchase Date": new DateTime.now()});
FlowsenseFlutterPlugin.shared.commitChanges();
```

## In App Analytics

You can track specific app events by passing an event name and an optional set of data in the form:

```
FlowsenseFlutterPlugin.shared.inAppEvent("eventName", {
    "buttonClicked": "OK",
    "dateClicked": new DateTime.now()
});
```

## Push notifications

For more information on Flowsense push, please refer to [link](https://docs.flowsense.com.br/pt/android/push_notifications/#notificacoes-push) and [link](https://docs.flowsense.com.br/pt/ios/push_notifications/#notificacoes-push).

### iOS

> Flowsense iOS SDK uses method swizzling by default. You can turn it off by adding to your app's Info.plist the following key: *FlowsenseCallbackSwizzlingEnabled* with a Boolean value of *NO*.
> 
> Note: by doing so, Flowsense won't be able to collect push analytics

On iOS, it is necessary to ask for push permission in runtime. Do so by requesting the token:

```
FlowsenseFlutterPlugin.shared.requestPushToken();
```

You can define a callback to retrieve the iOS token and to view the push permission status:

```
FlowsenseFlutterPlugin.shared.setPushTokenCallback((token){

});
FlowsenseFlutterPlugin.shared.setPushPermissionCallback((permission){

});
```

### Both platforms

It is possible to define callbacks that are called when a notification is either received and/or clicked:

```
FlowsenseFlutterPlugin.shared.setPushReceivedCallback((notification){
    
});
FlowsenseFlutterPlugin.shared.setPushClickedCallback((notification){

});
```
