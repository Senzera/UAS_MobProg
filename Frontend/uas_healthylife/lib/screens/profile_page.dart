import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late SharedPreferences prefs;
  TextEditingController usernameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController genderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeSharedPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 80,
                  backgroundImage: AssetImage('lib/assets/images/profile_image.jpeg'),
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[200],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    buildProfileField('Nama Pengguna', usernameController),
                    buildProfileField('Alamat', addressController),
                    buildProfileField('Jenis Kelamin', genderController),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        saveProfileData();
                      },
                      child: Text('Save'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Logout Confirmation'),
                        content: Text('Apakah Anda yakin ingin logout?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () {
                              _logout(context);
                            },
                            child: Text('Logout'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProfileField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 6.0),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Masukkan $label',
              border: InputBorder.none,
            ),
          ),
        ),
        SizedBox(height: 10.0),
      ],
    );
  }

  Future<void> initializeSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    loadProfileData();
  }

  void saveProfileData() {
    String userId = prefs.getString('userId') ?? ''; // Ambil ID pengguna dari SharedPreferences
    prefs.setString('username_$userId', usernameController.text); // Gunakan ID pengguna dalam key
    prefs.setString('address_$userId', addressController.text);
    prefs.setString('gender_$userId', genderController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Data berhasil disimpan.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void loadProfileData() {
    String userId = prefs.getString('userId') ?? ''; // Ambil ID pengguna dari SharedPreferences
    setState(() {
      usernameController.text = prefs.getString('username_$userId') ?? '';
      addressController.text = prefs.getString('address_$userId') ?? '';
      genderController.text = prefs.getString('gender_$userId') ?? '';
    });
  }

  void _logout(BuildContext context) {
    prefs.remove('token'); // Hapus token atau identifier login
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}
