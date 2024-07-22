import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:typed_data';

class PopupAlarm extends StatefulWidget {
  final String description;
  final int notificationId;

  PopupAlarm({required this.description, required this.notificationId});

  @override
  _PopupAlarmState createState() => _PopupAlarmState();
}

class _PopupAlarmState extends State<PopupAlarm> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    initializeNotifications();
  }

  Future<void> initializeNotifications() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('logolog3');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(widget.notificationId);
  }

  Future<void> addMore5Minutes() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final notificationTimeString = prefs.getString('notificationTime') ?? '';
    if (notificationTimeString.isNotEmpty) {
      final notificationTime = DateTime.parse(notificationTimeString);
      final newTime = notificationTime.add(Duration(minutes: 5));
      await scheduleNotification(newTime, widget.description, widget.notificationId);
      Navigator.of(context).pop();
    }
  }

  Future<void> scheduleNotification(DateTime notificationTime, String description, int notificationId) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel_id',
      'Channel Name',
      channelDescription: 'Channel Description',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([500, 1000, 500, 2000, 500, 3000]),
      enableLights: true,
      color: Colors.blue,
      timeoutAfter: 5000,
      onlyAlertOnce: false,
      fullScreenIntent: true,
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      'Reminder',
      'Time for your meal: $description',
      tz.TZDateTime.from(notificationTime, tz.local),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: description,
    );

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('notificationTime', notificationTime.toIso8601String());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Notification Action'),
      content: Text('What do you want to do with the reminder for: ${widget.description}?'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            cancelNotification();
            Navigator.of(context).pop();
          },
          child: Text('Turn Off Reminder'),
        ),
        TextButton(
          onPressed: () {
            addMore5Minutes();
          },
          child: Text('Add More 5 Minutes'),
        ),
      ],
    );
  }
}
