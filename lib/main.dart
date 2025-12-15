import 'package:flutter/material.dart';
import 'package:carryhub/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // auto-generated

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CarryHub',
      theme: ThemeData(primarySwatch: Colors.green),
      home:
          WelcomePage(), // or WelcomePage(), whichever you want as the first screen
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: ListView(children: [const WelcomeWidget()]));
  }
}

class WelcomeWidget extends StatelessWidget {
  const WelcomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth,
      height: screenHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFDDE5B6), // soft light green
            Color(0xFFA3C97B), // medium green
            Color(0xFF5FA153), // darker green
          ],
          stops: [0.0, 0.5, 1.0], // smooth transition
        ),
      ),

      child: Stack(
        children: [
          // Logo
          Align(
            alignment: Alignment(0, -0.4), // relative vertical position
            child: Container(
              width: screenWidth * 0.55, // 55% of screen width
              height: screenWidth * 0.55, // square container
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/carryhublogo.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // App Name
          Align(
            alignment: Alignment(0, 0.1), // center horizontally, slightly lower
            child: Text(
              'CarryHub',
              style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.06, // scales with screen width
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(
                    offset: Offset(0, 4),
                    blurRadius: 4,
                    color: Colors.black.withOpacity(0.25),
                  ),
                ],
              ),
            ),
          ),

          // Description
          Align(
            alignment: Alignment(0, 0.25), // slightly below app name
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
              child: Text(
                'Where students connect, collaborate, and \nget help with their projects',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.04,
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w400,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 4),
                      blurRadius: 4,
                      color: Colors.black.withOpacity(0.25),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Get Started Button
          Align(
            alignment: Alignment(0, 0.50), // lower part of the screen
            child: GestureDetector(
              onTap: () {
                // Navigate to the next screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Container(
                width: screenWidth * 0.4,
                height: screenHeight * 0.06,
                decoration: BoxDecoration(
                  color: Color(0xFFF0EAD2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.black.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(
                        93,
                        0,
                        0,
                        0,
                      ).withOpacity(0.25),
                      blurRadius: 6,
                      offset: Offset(0, 4), // x:0, y:4
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Get Started',
                    style: TextStyle(
                      color: Color(0xFF4B3827),
                      fontSize: screenWidth * 0.045,
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
