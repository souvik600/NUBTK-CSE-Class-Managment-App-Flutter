import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:nubtk_cse/Style/BottonStyle.dart';
import 'package:nubtk_cse/Style/InputDecorationStyle.dart';
import '../AppColors/AppColors.dart'; // Ensure this path is correct
import '../Style/BackgroundStyle.dart';
import '../Style/CustomAppBar.dart';
import '../Utility/Widgets/DateTimeWidget.dart';

// Main Screen
class AdminClassRoutineScreen extends StatelessWidget {
  const AdminClassRoutineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarStyle('Admin Class Routine'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            builder: (BuildContext context) {
              return AddClassScheduleScreen();
            },
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: AppColors.pColor,
      ),
    );
  }
}

// Class Routine Widget
class ClassRoutine extends StatelessWidget {
  final CollectionReference classRoutineCollection =
  FirebaseFirestore.instance.collection('class_routine');

  @override
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

          // Sort classes by time
          classes.sort((a, b) {
            DateTime timeA = DateFormat.jm().parse(a['time']!.split('-')[0].trim());
            DateTime timeB = DateFormat.jm().parse(b['time']!.split('-')[0].trim());
            return timeA.compareTo(timeB);
          });

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

class AddClassScheduleScreen extends StatefulWidget {
  @override
  _AddClassScheduleScreenState createState() => _AddClassScheduleScreenState();
}

class _AddClassScheduleScreenState extends State<AddClassScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dayController = TextEditingController();
  final _timeController = TextEditingController();
  final _subjectController = TextEditingController();
  final _classController = TextEditingController();
  final _roomController = TextEditingController();
  final _teacherController = TextEditingController();

  String? _selectedDay;

  List<String> daysOfWeek = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  Future<void> _addClass() async {
    if (_formKey.currentState?.validate() ?? false) {
      await FirebaseFirestore.instance.collection('class_routine').add({
        'day': _selectedDay,
        'classes': [
          {
            'time': _timeController.text,
            'subject': _subjectController.text,
            'class': _classController.text,
            'teacher': _teacherController.text,
            'room': _roomController.text,
          },
        ],
      });
      Navigator.pop(context);
    }
  }

  Future<void> _selectTimeRange() async {
    TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (startTime == null) return;

    TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (endTime == null) return;

    final start = DateFormat('h:mm a').format(DateTime(
      0,
      1,
      1,
      startTime.hour,
      startTime.minute,
    ));
    final end = DateFormat('h:mm a').format(DateTime(
      0,
      1,
      1,
      endTime.hour,
      endTime.minute,
    ));

    setState(() {
      _timeController.text = '$start - $end';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedDay,
                  items: daysOfWeek.map((day) {
                    return DropdownMenuItem<String>(
                      value: day,
                      child: Text(day),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDay = value;
                      _dayController.text = value ?? '';
                    });
                  },
                  decoration: AppInputDecoration('Day'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a day';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 6,),
                TextFormField(
                  controller: _timeController,
                  readOnly: true,
                  onTap: _selectTimeRange,
                  decoration: AppInputDecoration('Time'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the time';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 6,),
                TextFormField(
                  controller: _subjectController,
                  decoration: AppInputDecoration('Subject'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the subject';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 6,),
                TextFormField(
                  controller: _classController,
                  decoration: AppInputDecoration('Class'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the class';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 6,),
                TextFormField(
                  controller: _roomController,
                  decoration: AppInputDecoration('Room'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the room';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 6,),
                TextFormField(
                  controller: _teacherController,
                  decoration: AppInputDecoration('Teacher'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the teacher';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButtonStyle(
                  onPressed: _addClass,
                  text: 'Add Class',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}