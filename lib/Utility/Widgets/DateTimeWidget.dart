import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../AppColors/AppColors.dart';

class DateTimeWidget extends StatefulWidget {
  @override
  _DateTimeWidgetState createState() => _DateTimeWidgetState();
}

class _DateTimeWidgetState extends State<DateTimeWidget> {
  late String _currentTime;
  late String _currentDate;
  late String _currentDay;

  @override
  void initState() {
    super.initState();
    _updateTimeAndDate();
    // Update time and date every second
    Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimeAndDate();
    });
  }

  void _updateTimeAndDate() {
    setState(() {
      _currentTime = DateFormat.jm().format(DateTime.now());
      _currentDate = DateFormat.yMMMMd().format(DateTime.now());
      _currentDay = DateFormat.EEEE().format(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15, bottom: 20),
      width: MediaQuery.of(context).size.width,
      height: 55,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.pColor, // Use your desired color
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 6,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(CupertinoIcons.time, color: AppColors.spColor, size: 40),
          const SizedBox(width: 10),
          Text(
            '$_currentDay',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.spColor, // Use your desired color
              fontFamily: 'kalpurush',
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$_currentDate',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                  fontFamily: 'kalpurush',// Use your desired color
                ),
              ),
              Text(

                '$_currentTime',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'kalpurush',// Use your desired color
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
