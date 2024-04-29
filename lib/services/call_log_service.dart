
import 'package:flutter/services.dart';

class CallLogService {
  static const platform = MethodChannel('com.example.myapp/callLog');

  static void start() {
    platform.invokeMethod('startCallLogService');
  }
}
