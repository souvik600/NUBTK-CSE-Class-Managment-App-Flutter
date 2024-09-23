import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../AppColors/AppColors.dart';
import '../Style/BackgroundStyle.dart';
import 'HomeScreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 2),
          () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ScreenBackground(context),
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Colors.white, AppColors.pColor],
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Image.asset(
                        "assets/images/nubtk_logo.png",
                        height: 450.0,
                        width: 450.0,
                      ),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text(
                          "CSE 6A",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colorPurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 35.0,
                            fontFamily: 'poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 150),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
