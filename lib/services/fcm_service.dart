import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

Future<String> getAccessToken() async {
  final jsonString = await rootBundle.loadString(
    'assets/notifications_key/chat-app-6e218-bc873cfde4eb.json',
  );

  final accountCredentials = auth.ServiceAccountCredentials.fromJson(jsonString);
  final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
  final client = await auth.clientViaServiceAccount(accountCredentials, scopes);

  return client.credentials.accessToken.data;
}

Future<void> sendFCMNotification({
  required String token,
  required String title,
  required String body,
  required Map<String, String> data,
}) async {
  final accessToken = await getAccessToken();
  final fcmUrl = 'https://fcm.googleapis.com/v1/projects/chat-app-6e218/messages:send';

  final response = await http.post(
    Uri.parse(fcmUrl),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
    body: jsonEncode({
      'message': {
        'token': token,
        'notification': {
          'title': title,
          'body': body,
        },
        'data': data,
        'android': {
          'notification': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'channel_id': 'chat_channel',
            'sound': 'default'
          }
        },
        'apns': {
          'payload': {
            'aps': {'sound': 'default', 'content-available': 1}
          }
        },
      }
    }),
  );

  if (response.statusCode == 200) {
    print('Notification sent successfully');
  } else {
    print('Failed to send notification: ${response.body}');
  }
}


