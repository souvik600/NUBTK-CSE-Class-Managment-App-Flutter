import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../AppColors/AppColors.dart'; // Ensure this path is correct
import '../Style/BackgroundStyle.dart';
import '../Style/CustomAppBar.dart';
import '../Utility/Widgets/DateTimeWidget.dart';


class ClassRoutineScreen extends StatelessWidget {
  const ClassRoutineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarStyle('Class Routine'),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            ScreenBackground(context),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    width: MediaQuery.of(context).size.width,
                    height: 95,
                    child: DateTimeWidget(),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 580,
                    child: ClassRoutine(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Class Routine Widget
class ClassRoutine extends StatelessWidget {
  final CollectionReference classRoutineCollection =
  FirebaseFirestore.instance.collection('class_routine');

  @override
  Widget build(BuildContext context) {
    final currentDay = DateFormat('EEEE').format(DateTime.now());

    return StreamBuilder(
      stream: classRoutineCollection.snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final documents = snapshot.data?.docs ?? [];

        // Group documents by day
        final Map<String, List<Map<String, String>>> groupedDocuments = {};
        for (var doc in documents) {
          String day = doc['day'] ?? '';
          List<dynamic> classesList = doc['classes'] ?? [];
          List<Map<String, String>> classes = classesList.map((item) {
            return Map<String, String>.from(item as Map);
          }).toList();

          if (!groupedDocuments.containsKey(day)) {
            groupedDocuments[day] = [];
          }
          groupedDocuments[day]!.addAll(classes);
        }

        // Get all days and sort them with the current day first
        final sortedDays = groupedDocuments.keys.toList()
          ..sort((a, b) {
            if (a == currentDay) return -1;
            if (b == currentDay) return 1;
            return a.compareTo(b);
          });

        return ListView(
          scrollDirection: Axis.horizontal,
          children: sortedDays.map((day) {
            return DaySchedule(
              day: day,
              classes: groupedDocuments[day]!,
              isCurrentDay: day == currentDay,
            );
          }).toList(),
        );
      },
    );
  }
}

// Day Schedule Widget
class DaySchedule extends StatelessWidget {
  final String day;
  final List<Map<String, String>> classes;
  final bool isCurrentDay;

  const DaySchedule({
    required this.day,
    required this.classes,
    required this.isCurrentDay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
        color: isCurrentDay ? Colors.red.withOpacity(.2) : AppColors.pColor.withOpacity(.2),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 45,
              decoration: BoxDecoration(
                color: isCurrentDay ? Colors.red.withOpacity(.8) : AppColors.pColor.withOpacity(.8),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [BoxShadow(blurRadius: 5.0, color: Colors.black45)],
              ),
              child: Center(
                child: Text(
                  day,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 25,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: classes.map((classDetails) {
                return ClassDetails(classDetails: classDetails, isCurrentDay: isCurrentDay);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// Class Details Widget
class ClassDetails extends StatelessWidget {
  final Map<String, String> classDetails;
  final bool isCurrentDay;

  const ClassDetails({
    required this.classDetails,
    required this.isCurrentDay,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentTime = DateFormat('HH:mm').format(now);
    final classTime = classDetails['time']!.split('-')[0].trim();
    final isCurrentClass = isCurrentDay && classTime == currentTime;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isCurrentClass ? Colors.yellow.withOpacity(0.3) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(blurRadius: 5.0, color: Colors.black45)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.spColor),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              children: [
                Center(child: Text(classDetails['class']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
                Center(child: Text(classDetails['subject']!, style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 13))),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Center(child: Text(classDetails['time']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.deepPurple))),
          Center(child: Text(classDetails['teacher']!, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16))),
          Center(child: Text("Room No: ${classDetails['room']}", style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14))),
        ],
      ),
    );
  }
}


