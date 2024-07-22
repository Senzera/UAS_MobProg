import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'adjust_meals.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';

  class MealsPage extends StatefulWidget {
    @override
    MealsPageState createState() => MealsPageState();
  }

  class MealsPageState extends State<MealsPage> {
  late String authToken;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late List<Meal> meals = [];
  TimeOfDay reminderTime = TimeOfDay.now();
  Color circleColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    initializeData();
    initializeNotifications();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
  await Permission.notification.request();
}

  Future<void> initializeNotifications() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('logolog3');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);



    void onSelectNotification(NotificationResponse notification) {
      String? payload = notification.payload;
      if (payload != null) {
        showNotificationActionDialog(payload);
      }
    }

  await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onSelectNotification,
    );

    print('Notifications initialized');
  }


Future<void> scheduleNotification(DateTime notificationTime, String description) async {
 final AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
  'channel_id',
  'Channel Name',
  channelDescription: 'Channel Description',
  importance: Importance.max,
  priority: Priority.max,
  playSound: true,
  sound: RawResourceAndroidNotificationSound('alarmkuu'),
  enableVibration: true,
  vibrationPattern: Int64List.fromList([500, 1000, 500, 2000, 500, 3000]),
  
);
var initializationSettingsAndroid = AndroidInitializationSettings('alarmkuu');
var initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
await flutterLocalNotificationsPlugin.initialize(initializationSettings);


   // Logging untuk memastikan bahwa notifikasi dijadwalkan dengan benar
  print('Scheduling notification for $notificationTime with description: $description');

  if (notificationTime.isBefore(DateTime.now())) {
    notificationTime = DateTime.now().add(Duration(minutes: 1));
    print('Notification time is in the past. Rescheduling to $notificationTime');
  }

  final NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    'Reminder',
    'Waktu makan Anda: $description',
    tz.TZDateTime.from(notificationTime, tz.local),
    platformChannelSpecifics,
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    payload: description,
  );
}

void onNotificationArrived(String description) {
  showNotificationActionDialog(description);
}

void showNotificationActionDialog(String description) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Notification Action'),
        content: Text('What do you want to do with the reminder for: $description?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              // Turn off reminder logic
              cancelNotification(); // Gantikan dengan logika Anda
              Navigator.of(context).pop();
            },
            child: Text('Turn Off Reminder'),
          ),
          TextButton(
            onPressed: () {
              // Add more 5 minutes logic
              addMore5Minutes(); // Gantikan dengan logika Anda
              Navigator.of(context).pop();
            },
            child: Text('Add More 5 Minutes'),
          ),
        ],
      );
    },
  );
}

// Fungsi untuk menambah 5 menit pada notifikasi
void addMore5Minutes() async {
  final notificationTime = await getNotificationTime();
  if (notificationTime != null) {
    final newTime = notificationTime.add(Duration(minutes: 5));
    await scheduleNotification(newTime, 'Updated meal time');
  } else {
    print('Notification time is not available');
  }
}

// Fungsi untuk mendapatkan waktu notifikasi
Future<DateTime?> getNotificationTime() async {
  // Gantikan dengan logika untuk mendapatkan waktu notifikasi yang sesuai
  return Future.value(DateTime.now()); // Misalnya mengembalikan reminderTime
}


  Future<void> cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0); 
  }

  Future<void> initializeData() async {
    authToken = await getAuthToken();
    await fetchMealsFromDatabase();
  }

  Future<String> getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

Future<void> fetchMealsFromDatabase() async {
  final url = 'http://healthylifes.c1.is/api/reminders';
  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        meals = data.map((item) => Meal.fromJson(item)).toList();
        meals.sort((a, b) {
          final aTime = DateTime(0, 1, 1, a.time.hour, a.time.minute);
          final bTime = DateTime(0, 1, 1, b.time.hour, b.time.minute);
          return aTime.compareTo(bTime);
        });

        final now = DateTime.now(); 
        meals.forEach((meal) {
          final mealTime = DateTime(now.year, now.month, now.day, meal.time.hour, meal.time.minute);
          scheduleNotification(mealTime, meal.description);
        });
      });
    } else {
      print('Gagal mengambil pengingat: ${response.statusCode}');
      print('Body respons: ${response.body}');
    }
  } catch (error) {
    print('Error fetch pengingat: $error');
  }
}


  void _showDeleteConfirmationDialog(int mealId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Reminder'),
          content: Text('Are you sure you want to delete this reminder?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await deleteMeal(mealId);
                await fetchMealsFromDatabase();
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteMeal(int mealId) async {
    final url = 'http://healthylifes.c1.is/api/reminders/$mealId';
    print('Deleting meal with ID: $mealId');
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        await fetchMealsFromDatabase();
      } else {
        print('Failed to delete meal: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      print('Error deleting meal: $error');
    }
  }

  Future<void> updateMeal(Meal meal) async {
    final url = 'http://healthylifes.c1.is/api/reminders/${meal.id}';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(meal.toJson()),
      );

      if (response.statusCode == 200) {
        setState(() {
          meals.removeWhere((meal) => meal.id == meal);
          int index = meals.indexWhere((m) => m.id == meal.id);
          if (index != -1) {
            meals[index] = meal;
          }
        });
        // Schedule a notification with the updated time
        final now = DateTime.now();
        final updatedNotificationTime = DateTime(now.year, now.month, now.day, meal.time.hour, meal.time.minute);
        await scheduleNotification(updatedNotificationTime, meal.description);
      } else {
        print('Failed to update meal: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      print('Error updating meal: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade700, Colors.green.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'lib/assets/images/logolog3.png',
                        width: 30,
                        height: 30,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'HealthyLife',
                        style: TextStyle(
                          fontSize: 25,
                          fontFamily: 'Nightday',
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  // Kotak dengan lengkungan di bawah logo
                  Container(
                    width: double.infinity,
                    height: 100, // Ukuran panjang kotak
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Lingkaran oren dengan padding
                    Padding(
                      padding: EdgeInsets.only(left: 40), // Sesuaikan nilai padding sesuai dengan kebutuhan
                      child: SizedBox(
                        width: 50,
                        height: 80,
                        child: CustomPaint(
                          foregroundPainter: CircleProgressBar(
                            completePercentage: meals.isNotEmpty
                                ? (meals.where((meal) => meal.isCompleted).length / meals.length * 100).toInt()
                                : 0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 60), // Jarak antara lingkaran oren dan ikon garpu
                    // Icon garpu dan sendok
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          color: Colors.orange,
                          size: 30,
                        ),
                        SizedBox(height: 10),
                        Text(
                          '${meals.isNotEmpty ? meals.where((meal) => meal.isCompleted).length : 0}/${meals.length}',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 50), // Jarak antara ikon garpu dan paragraf "Next Meal"
                    // Paragraf kecil Next Meal
                    Expanded(
                      child: FutureBuilder(
                        future: getNextMealTime(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else {
                            if (snapshot.hasError) {
                              return Text(
                                'Error',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              );
                            } else {
                              return Text(
                                snapshot.data.toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
                  ),                  
                  SizedBox(height: 20), // Ukuran tinggi kotak
                ],
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Your Meals',
                style: TextStyle(fontSize: 15),
              ),
            ),
            SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: meals.length,
              itemBuilder: (context, index) {
                return _buildMealCard(meals[index]);
              },
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdjustMealsPage()),
                ).then((value) => fetchMealsFromDatabase());
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[200],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Add Your Reminder Meal',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(width: 10),
                    Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.green.shade200,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.add,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildMealCard(Meal meal) {
  final timeText = DateFormat('HH:mm').format(DateTime(0, 1, 1, meal.time.hour, meal.time.minute));

  return GestureDetector(
    onTap: () {
      _showStatusDialog(meal);
    },
    child: Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: meal.isCompleted ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.description,
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 5),
                Text(
                  timeText,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              _showEditDialog(meal);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmationDialog(meal.id);
            },
          ),
        ],
      ),
    ),
  );
}


void _showEditDialog(Meal meal) {
  final descriptionController = TextEditingController(text: meal.description);
  TimeOfDay selectedTime = meal.time;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Edit Meal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(hour: meal.time.hour, minute: meal.time.minute),
                  builder: (BuildContext context, Widget? child) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                      child: child!,
                    );
                  },
                );
                  if (picked != null && picked != selectedTime) {
                   setState(() {
                    selectedTime = picked;
                });
              }
              },
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Time',
                    hintText: '${selectedTime.format(context)}',
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              setState(() {
                meal.description = descriptionController.text;
                meal.time = selectedTime;
              });
              updateMeal(meal);
              Navigator.of(context).pop();
            },
            child: Text('Save'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
        ],
      );
    },
  );
}

  Future<void> _showStatusDialog(Meal meal) async {
    bool? newStatus = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Reminder Status'),
        content: Text('Is this meal completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes'),
          ),
        ],
      ),
    );

    if (newStatus != null) {
      final updatedMeal = Meal(
        id: meal.id,
        description: meal.description,
        time: meal.time,
        isCompleted: newStatus,
      );

      updateMeal(updatedMeal);
    }
  }

  Future<String> getNextMealTime() async {
    meals.sort((a, b) => a.time.hour.compareTo(b.time.hour));
    final now = DateTime.now();
    Meal? nextMeal;

    for (final meal in meals) {
      final mealTime = DateTime(now.year, now.month, now.day, meal.time.hour, meal.time.minute);
      if (mealTime.isAfter(now)) {
        nextMeal = meal;
        break;
      }
    }

    if (nextMeal != null) {
      final nextMealTime = DateTime(now.year, now.month, now.day, nextMeal.time.hour, nextMeal.time.minute);
      final difference = nextMealTime.difference(now);
      final formattedTime = '${difference.inHours}h ${difference.inMinutes.remainder(60)}m';
      return 'Next meal: ${nextMeal.description} in $formattedTime';
    } else {
      return 'No upcoming meals';
    }
  }
}



class CircleProgressBar extends CustomPainter {
  final int completePercentage;

  CircleProgressBar({required this.completePercentage});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint outerCircle = Paint()
      ..strokeWidth = 7
      ..color = Colors.green.shade700
      ..style = PaintingStyle.stroke;

    final Paint completeArc = Paint()
      ..strokeWidth = 7
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2;

    canvas.drawCircle(center, radius, outerCircle);

    double arcAngle = 2 * math.pi * (completePercentage / 100); // Menggunakan math.pi
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      arcAngle,
      false,
      completeArc,
    );
  }

  @override
    bool shouldRepaint(CircleProgressBar oldDelegate) {
    return oldDelegate.completePercentage != completePercentage;
  }
}


class Meal {
  final int id;
  String description;
  TimeOfDay time;
  final bool isCompleted;

  Meal({
    required this.id,
    required this.description,
    required this.time,
    required this.isCompleted,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    // final timeString = json['time'] as String;
    // final timeParts = timeString.split(':');
    // final hour = int.parse(timeParts[0]);
    // final minute = int.parse(timeParts[1]);

    return Meal(
      id: json['id'],
      description: json['description'],
      time: TimeOfDay(
        hour: int.parse(json['time'].substring(0, 2)),
        minute: int.parse(json['time'].substring(3, 5)),
      ),
      isCompleted: json['is_completed'] ?? false, // Nilai default false jika null
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'time': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
        'is_completed': isCompleted,
      };
}