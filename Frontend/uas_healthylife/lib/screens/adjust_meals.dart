import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class AdjustMealsPage extends StatefulWidget {
  @override
  _AdjustMealsPageState createState() => _AdjustMealsPageState();
}

class _AdjustMealsPageState extends State<AdjustMealsPage> {
  List<Meal> meals = [];

  late String authToken; // Declare authToken
  late int userId;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    authToken = await getAuthToken(); // Get authToken from SharedPreferences
    userId = await getUserId();
    await fetchMealsFromDatabase();
  }

  Future<String> getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? ''; // Return authToken from SharedPreferences
  }

  Future<int> getUserId() async {
    // Replace with your logic to retrieve user ID
    return 1;
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
        });
      } else {
        print('Failed to fetch meals: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      print('Error fetching meals: $error');
    }
  }

  Future<void> _addMeal() async {
    setState(() {
      meals.add(Meal(description: 'Add New Meal', time: TimeOfDay.now()));
    });
  }

  void _deleteMeal(int index) {
    setState(() {
      meals.removeAt(index);
    });
  }

Future<void> _editMeal(int index) async {
  final TimeOfDay? pickedTime = await showTimePicker(
    context: context,
    initialTime: meals[index].time,
    builder: (context, child) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      );
    },
  );
  if (pickedTime != null) {
    setState(() {
      meals[index].time = pickedTime;
    });
  }
}


Future<void> _saveMeals() async {
  final url = 'http://healthylifes.c1.is/api/reminders';
  try {
    for (var meal in meals) {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'description': meal.description,
          'time': '${meal.time.hour.toString().padLeft(2, '0')}:${meal.time.minute.toString().padLeft(2, '0')}',
          'user_id': userId,
        }),
      );

      if (response.statusCode == 201) {
        print('Meal saved: ${meal.description}');
      } else {
        print('Failed to save meal: ${meal.description}');
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    }

    Navigator.pushReplacementNamed(context, '/home');
  } catch (error) {
    print('Error saving meals: $error');
  }
}



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Menutup keyboard saat tap di luar TextField
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Adjust Meals'),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10),

              // Logo dan nama aplikasi
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
                          fontSize: 5,
                          fontFamily: 'Nightday',
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),


              SizedBox(height: 20),

              Center(
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade700, Colors.green.shade200],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Image.asset(
                    'lib/assets/images/pancik.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              SizedBox(height: 10),

              Center(
                child: Text(
                  'Adjust meals',
                  style: TextStyle(fontSize: 28),
                ),
              ),

              SizedBox(height: 20),

              Column(
                children: meals.asMap().entries.map((entry) {
                  int idx = entry.key;
                  Meal meal = entry.value;
                  return Column(
                    children: [
                      _buildAdjustBox(meal, idx),
                      SizedBox(height: 10), // Jarak antar entri
                    ],
                  );
                }).toList(),
              ),

              Center(
                child: GestureDetector(
                  onTap: _addMeal,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    margin: EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.red.shade100,
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
                        Icon(Icons.add, color: Colors.red.shade700),
                        SizedBox(width: 10),
                        Text(
                          'Add New Meal',
                          style: TextStyle(fontSize: 18, color: Colors.red.shade700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20), // Jarak antara tabel dan tombol simpan

              _buildSaveButton(context, 500, 50), // Tombol simpan
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdjustBox(Meal meal, int index) {
    final timeText = DateFormat.Hm().format(DateTime(0, 1, 1, meal.time.hour, meal.time.minute));
    return Container(
      width: double.infinity,
      height: 55, // Tinggi kotak
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0), // Mengubah padding agar konten berada di tengah
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6, // Lebar sesuai dengan proporsi
              child: TextField(
                onChanged: (value) {
                  meal.description = value;
                },
                decoration: InputDecoration(
                  hintText: 'Description',
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green.shade700), // Mengubah warna garis menjadi hijau
                  ),
                ),
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _editMeal(index),
            child: Text(
              timeText,
              style: TextStyle(fontSize: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap: () => _deleteMeal(index),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent, // Menghilangkan background color
                ),
                child: Icon(Icons.remove, color: Colors.green.shade700, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, double width, double height) {
    return Container(
      width: width,
      height: height,
      margin: EdgeInsets.symmetric(horizontal: 16.0), // Jarak antara tombol dan elemen sekitarnya
      child: ElevatedButton(
        onPressed: _saveMeals,
        child: Text(
          'Save',
          style: TextStyle(fontSize: 20),
        ),
        style: ElevatedButton.styleFrom(
          primary: Colors.green.shade700,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

class Meal {
  late String description;
  late TimeOfDay time;

  Meal({required this.description, required this.time});

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      description: json['description'],
      time: TimeOfDay(hour: int.parse(json['time'].split(':')[0]), minute: int.parse(json['time'].split(':')[1])),
    );
  }
}
