import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/services.dart';






class MqttManager {
  static const MethodChannel _channel = MethodChannel('samples.flutter.dev/mqtt');
 // static const MethodChannel _k = MethodChannel('samples.flutter.dev/mqttback');

  MqttManager() {
    // Set up the MethodCallHandler
  _channel.setMethodCallHandler((call) async {
        print("the method handler called");
      switch (call.method) {
      
        case 'onDataReceived':
          String receivedData = call.arguments;
          // Handle the received data in your Flutter code
          print('Received data from Android: $receivedData');
          // You can call a method or update a state with the received data
          break;
        // Add more cases as needed
        // ...
      }
    });

    // Add other initialization code if needed
  }
  static Future<void> connectMqtt(String brokerUrl, String clientId) async {
    try {
      await _channel.invokeMethod('connectMqtt', {'brokerUrl': brokerUrl, 'clientId': clientId});
    
    } on PlatformException catch (e) {
      print('Error connecting to MQTT: ${e.message}');
    }
  }

  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _channel.invokeMethod('subscribeToTopic', {'topic': topic});
    
    } on PlatformException catch (e) {
      print('Error subscribing to topic: ${e.message}');
    }
  }

  static Future<void> publishMessage(String topic, String message) async {
    try {
      await _channel.invokeMethod('publishMessage', {'topic': topic, 'message': message});
  
    } on PlatformException catch (e) {
      print('Error publishing message: ${e.message}');
    }
  }


    static Future<void> disconnect() async {
    try {
      print("in mqtt disconnect");
      await _channel.invokeMethod('disconnect');
    } on PlatformException catch (e) {
      print('Error disconnecting from MQTT: ${e.message}');
    }
  }

  static Future<void> unsubscribe(String topic) async {
    try {
      await _channel.invokeMethod('unsubscribe', {'topic': topic});
    } on PlatformException catch (e) {
      print('Error unsubscribing from topic: ${e.message}');
    }
  }
}
