package com.flowsense.flowsense_flutter_plugin;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import com.flowsense.flowsensesdk.PushNotification.FlowsensePushService;
import com.flowsense.flowsensesdk.PushNotification.FlowsenseNotification;
import com.flowsense.flowsensesdk.PushNotification.PushCallbacks;
import com.flowsense.flowsensesdk.PushNotification.FCM.FlowsenseHandlePush;
import com.flowsense.flowsensesdk.InAppEvent.InAppEvent;
import com.flowsense.flowsensesdk.FlowsenseSDK;
import com.flowsense.flowsensesdk.AppUsage.MonitorAppUsage;
import com.flowsense.flowsensesdk.KeyValues.KeyValuesManager;

import android.app.Application;
import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.util.Log;
import android.content.Intent;
import android.os.Bundle;
import android.content.IntentFilter;

import androidx.core.app.ActivityCompat;
import android.os.Build;
import android.content.pm.PackageManager;

import java.util.HashMap;
import java.util.Map;
import java.lang.reflect.Method;
import java.util.Iterator;
import java.util.Set;
import java.util.Date;

import org.json.JSONArray;
import org.json.JSONObject;
import org.json.JSONException;

/** FlowsenseFlutterPlugin */
public class FlowsenseFlutterPlugin implements MethodCallHandler, PushCallbacks, PluginRegistry.RequestPermissionsResultListener {
  /** Plugin registration. */
  private Registrar flutterRegistrar;
  private MethodChannel channel;

  public static String RECEIVED_PUSH = "PUSH_RECEIVED";
  public static String CLICKED_PUSH = "PUSH_CLICKED";

  private static final int MY_PERMISSIONS_ACCESS_FINE_LOCATION = 122;

  public static void registerWith(Registrar registrar) {
    final MethodChannel methodChannel = new MethodChannel(registrar.messenger(), "FlowsenseSDK");
    methodChannel.setMethodCallHandler(new FlowsenseFlutterPlugin(registrar.context(), methodChannel, registrar));
  }

  public FlowsenseFlutterPlugin(Context context, MethodChannel methodChannel, Registrar registrar) {
    this.flutterRegistrar = registrar;
    this.channel = methodChannel;
    this.channel.setMethodCallHandler(this);
    try {
      MonitorAppUsage.getInstance(
              (Application) context.getApplicationContext());
    } catch (Exception e) {
        e.printStackTrace();
        Log.e("FlowsenseSDK", e.toString());
    }
  }
  
  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("FlowsenseSDK#startFlowsense")) {
      startFlowsense();
    } else if (call.method.equals("FlowsenseSDK#startFlowsenseService")) {
      startFlowsenseService(call, result);
    } else if (call.method.equals("FlowsenseSDK#requestAlwaysAuthorization")) {
      requestAlwaysAuthorization();
    } else if (call.method.equals("FlowsenseSDK#startMonitoringLocation")) {
      startMonitoringLocation();
    } else if (call.method.equals("FlowsenseSDK#updatePartnerUserId")) {
      updatePartnerUserId(call, result);
    } else if (call.method.equals("FlowsenseSDK#setKeyValue")) {
      setKeyValue(call, result);
    } else if (call.method.equals("FlowsenseSDK#commitChanges")) {
      commitChanges(call, result);
    } else if (call.method.equals("FlowsenseSDK#sendMessageToFlowsense")) {
      sendMessageToFlowsense(call, result);
    } else if (call.method.equals("FlowsenseSDK#inAppEvent")) {
      inAppEvent(call, result);
    } else {
      result.notImplemented();
    }
  }

  private Context getApplicationContext() {
    return flutterRegistrar.activeContext();
  }

  private void startFlowsense(){
    FlowsensePushService.getInstance().setPushCallback(this);

    receivedNotifReceiver();
    clickedNotifReceiver();
  }

  private JSONObject flowsenseNotificationToJson(FlowsenseNotification notification) {
    JSONObject jsonObject = new JSONObject();
    try {
        jsonObject.put("is_flowsense", true);
        jsonObject.put("title", notification.getTitle());
        jsonObject.put("small_message", notification.getSmallMessage());
        jsonObject.put("big_message", notification.getBigMessage());
        jsonObject.put("action", notification.getAction());
        jsonObject.put("push_image_icon_url", notification.getBigIconURL());
        jsonObject.put("push_image_url", notification.getBigPictureURL());
        JSONObject dataObj = new JSONObject();
        dataObj.put("push_uuid", notification.getPushUUID());
        dataObj.put("app_uri", notification.getAppURI());
        dataObj.put("intent_extras", notification.getIntentExtras().toString());

        JSONArray jsonArray = new JSONArray();
        for (Bundle b : notification.getActionButtons()) {
            jsonArray.put(bundleToJSON(b));
        }
        dataObj.put("actionButtons", jsonArray);
        jsonObject.put("data", dataObj);
    } catch (Exception e) {
        Log.e("FlowsenseSDK", e.getMessage());
    }
    return jsonObject;
}

  private JSONObject bundleToJSON(Bundle bundle){
    JSONObject json = new JSONObject();
    Set<String> keys = bundle.keySet();
    for (String key : keys) {
        try {
            if (bundle.get(key) instanceof Bundle){
                json.put(key, bundleToJSON((Bundle) bundle.get(key)));
            }
            json.put(key, bundle.get(key));
        } catch(JSONException e) {
            //Handle exception here
            Log.e("FlowsenseSDK", e.getMessage());
        }
    }
    return json;
  }

  private void receivedNotifReceiver(){
    final MethodChannel c = this.channel;
    IntentFilter intentFilter = new IntentFilter(RECEIVED_PUSH);
    getApplicationContext().registerReceiver(new BroadcastReceiver() {
      @Override
      public void onReceive(Context context, Intent intent) {
        try {
          FlowsenseNotification flowsenseNotification = (FlowsenseNotification)
                            intent.getSerializableExtra("notification");
          JSONObject jsonObject = flowsenseNotificationToJson(flowsenseNotification);
          Log.v("FlowsenseSDK", "Received Push Notification");
          c.invokeMethod("FlowsenseSDK#receivedNotification", jsonToWritableMap(jsonObject));
        }
        catch (Exception e){
          Log.e("FlowsenseSDK", e.getMessage());
        }
      }
    }, intentFilter);
  }

  private void clickedNotifReceiver(){
    final MethodChannel c = this.channel;
    IntentFilter intentFilter = new IntentFilter(CLICKED_PUSH);
    getApplicationContext().registerReceiver(new BroadcastReceiver() {
      @Override
      public void onReceive(Context context, Intent intent) {
        try {
          FlowsenseNotification flowsenseNotification = (FlowsenseNotification)
                            intent.getSerializableExtra("notification");
          JSONObject jsonObject = flowsenseNotificationToJson(flowsenseNotification);
          Log.v("FlowsenseSDK", "Clicked Push Notification");
          c.invokeMethod("FlowsenseSDK#clickedNotification", jsonToWritableMap(jsonObject));    
        }
        catch (Exception e){
          Log.e("FlowsenseSDK", e.getMessage());
        }
      }
    }, intentFilter);
  }

  @Override
  public void receivedNotification(FlowsenseNotification notification) {
    Log.v("FlowsenseSDK", "Received Push Notification Callback");  
    final Intent intent = new Intent(FlowsenseFlutterPlugin.RECEIVED_PUSH);
      intent.putExtra("notification", notification);
      getApplicationContext().sendBroadcast(intent);
  }

  @Override
  public void clickedNotification(FlowsenseNotification notification) {
      Log.v("FlowsenseSDK", "Clicked Push Notification Callback");
      final Intent intent = new Intent(FlowsenseFlutterPlugin.CLICKED_PUSH);
      intent.putExtra("notification", notification);
      getApplicationContext().sendBroadcast(intent);
  }

  private void startFlowsenseService(MethodCall call, Result result) {
    String token = call.argument("authToken");
    FlowsenseSDK.init(token, getApplicationContext());
    result.success(null);
  }

  private void startMonitoringLocation(){
    this.requestAuthAndStartLocation();
  }

  private void requestAlwaysAuthorization(){
    this.requestAuthAndStartLocation();
  }

  private void requestAuthAndStartLocation(){
    Context context = getApplicationContext();
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            if (context.checkSelfPermission(android.Manifest.permission.ACCESS_BACKGROUND_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                try {
                  ActivityCompat.requestPermissions(flutterRegistrar.activity(), new String[]{android.Manifest.permission.ACCESS_BACKGROUND_LOCATION, 
                    android.Manifest.permission.ACCESS_FINE_LOCATION}, 
                    MY_PERMISSIONS_ACCESS_FINE_LOCATION);                  
                } catch (Exception e) {
                    Log.e("FlowsenseSDK", e.getMessage());
                }
            }
        }
        else if (context.checkSelfPermission(android.Manifest.permission.ACCESS_FINE_LOCATION) !=
                PackageManager.PERMISSION_GRANTED) {            
            try {
              ActivityCompat.requestPermissions(flutterRegistrar.activity(), new String[]{android.Manifest.permission.ACCESS_FINE_LOCATION}, 
                MY_PERMISSIONS_ACCESS_FINE_LOCATION);
            } catch (Exception e) {
                Log.e("FlowsenseSDK", e.getMessage());
            }
        }
    } else {
        FlowsenseSDK.startMonitoringLocation(context);
    }
  }

  private void updatePartnerUserId(MethodCall call, Result result) {
    String userID = call.argument("userID");
    FlowsenseSDK.updatePartnerUserId(userID, getApplicationContext());
    result.success(null);
  }

  private void setKeyValue(MethodCall call, Result result) {
    try {
      if (call.argument("keyValues") instanceof HashMap) {
        HashMap map = call.argument("keyValues");
        KeyValuesManager keyValuesManager = new KeyValuesManager(getApplicationContext());
        for ( Object key : map.keySet() ) {
          String keyString = key.toString();
          Object obj = map.get(keyString);

          if (keyString.contains("FSDate_")) {
            keyString = keyString.replace("FSDate_", "");
            obj = new Date((Long) obj);
          }

          Method method = keyValuesManager.getClass().getMethod("setKeyValues", String.class, obj.getClass());
          method.invoke(keyValuesManager, keyString, obj);
        }
        result.success(null);
      } else {
        result.error("", "Cannot parse arguments, they must be a Map of one key-value pair", null);
      }
    } catch (Exception e) {
      e.printStackTrace();
      Log.e("FlowsenseSDK", e.getMessage());
    }
  }

  private void commitChanges(MethodCall call, Result result) {
    new KeyValuesManager(getApplicationContext()).commitChanges();
    result.success(null);
  }

  private static HashMap<String, Object> jsonToWritableMap(JSONObject jsonObject) {
      HashMap<String, Object> writableMap = new HashMap();

      if (jsonObject == null) {
          return null;
      }


      Iterator<String> iterator = jsonObject.keys();
      if (!iterator.hasNext()) {
          return null;
      }

      while (iterator.hasNext()) {
          String key = iterator.next();

          try {
              Object value = jsonObject.get(key);

              if (value == null) {
                  writableMap.put(key, null);
              } else if (value instanceof Boolean) {
                  writableMap.put(key, (Boolean) value);
              } else if (value instanceof Integer) {
                  writableMap.put(key, (Integer) value);
              } else if (value instanceof Double) {
                  writableMap.put(key, (Double) value);
              } else if (value instanceof String) {
                  writableMap.put(key, (String) value);
              } else if (value instanceof JSONObject) {
                  writableMap.put(key, jsonToWritableMap((JSONObject) value));
              }
          } catch (JSONException ex) {
              // Do nothing and fail silently
          }
      }

      return writableMap;
  }

  private void sendMessageToFlowsense(MethodCall call, Result result) {
    if (call.arguments() instanceof HashMap) {
      HashMap map = call.arguments();
      new FlowsenseHandlePush(getApplicationContext(), toMap(map, false));
      result.success(null);
    }
    else {
      result.error("", "Cannot parse arguments, they must be a Map of one key-value pair", null);
    }
  }

  private static Map<String, String> toMap(HashMap readableMap, boolean recursion) {
    Map<String, String> map = new HashMap<>();

    for (Object keyObj : readableMap.keySet()) {
        String key = keyObj.toString();
        
        Object obj = readableMap.get(key);

        if (obj == null) {
          map.put(key, "");
        } else if (obj instanceof Boolean) {
          map.put(key, String.valueOf(obj));
        } else if (obj instanceof Number) {
          map.put(key, String.valueOf(obj));
        } else if (obj instanceof String) {
          if (recursion) map.put(key, "\"" + obj + "\"");
          else map.put(key, String.valueOf(obj));
        } else if (obj instanceof Map) {
            map.put(key, toMap((HashMap) obj, true).toString());
        }
    }
    return map;
  }

  private void inAppEvent(MethodCall call, Result result) {
    String eventName = call.argument("eventName");
    try {
      HashMap<String, Object> eventMap = call.argument("eventMap");
      HashMap<String, Object> eMap = new HashMap();
      for (String key : eventMap.keySet()) {
        if (key.contains("FSDate_")) {
          Object value = eventMap.get(key);
          eMap.put(key.replace("FSDate_", ""), new Date((Long) eventMap.get(key)));
        } else {
          eMap.put(key, eventMap.get(key));
        }
      }
      new InAppEvent().SaveAndSendEvent(getApplicationContext(), eventName, eMap);
    } catch (Exception e) {
      e.printStackTrace();
      Log.e("FlowsenseSDK", "Could not read event map");
      result.error("", "Cannot parse arguments, they must be a Map of key-value pairs", null);
    }
    result.success(null);
  }

  @Override
  public boolean onRequestPermissionsResult(int requestCode, String[] strings, int[] ints) {
    switch (requestCode) {
      case MY_PERMISSIONS_ACCESS_FINE_LOCATION: {
          // If request is cancelled, the result arrays are empty.
          if (ints.length > 0 && ints[0] == PackageManager.PERMISSION_GRANTED) {
              FlowsenseSDK.startMonitoringLocation(getApplicationContext());
          }
      }
    }
    return false;
  }
}
