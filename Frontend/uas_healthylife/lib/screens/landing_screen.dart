import 'package:flutter/material.dart';

class LandingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(flex: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'lib/assets/images/logolog3.png',
                  width: 50,
                  height: 40,
                ),
                SizedBox(width: 5),
                Text(
                  'HealthyLife',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontFamily: 'Nightday',
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            Image.asset(
              'lib/assets/images/lp.png',
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 10),
            Text(
              'Welcome to the HealthyLife App',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
              'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
              'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris '
              'nisi ut aliquip ex ea commodo consequat.',
              style: TextStyle(
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            Spacer(flex: 3),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text('Next'),
              style: ElevatedButton.styleFrom(
                primary: Colors.purple[300], 
                onPrimary: Colors.black, 
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), 
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
