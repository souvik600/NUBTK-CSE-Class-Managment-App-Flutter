import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../AppColors/AppColors.dart';
import '../Style/BackgroundStyle.dart';
import '../Style/CustomAppBar.dart';
import '../Style/BottonStyle.dart';
import '../Style/InputDecorationStyle.dart';
import '../Utility/Widgets/DateTimeWidget.dart';

class AdminExamRoutineScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarStyle('Exam Routine'),
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
                    child: ExamRoutineList(),
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
              return AddOrEditExamRoutineScreen();
            },
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: AppColors.spColor,
      ),
    );
  }
}

class ExamRoutineList extends StatefulWidget {
  @override
  _ExamRoutineListState createState() => _ExamRoutineListState();
}

class _ExamRoutineListState extends State<ExamRoutineList> {
  final CollectionReference examCollection =
  FirebaseFirestore.instance.collection('exam_routine');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: examCollection.snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple));
        }

        final exams = snapshot.data?.docs ?? [];

        return ListView.builder(
          itemCount: exams.length,
          itemBuilder: (context, index) {
            final exam = exams[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2.0,
                  margin: const EdgeInsets.all(5.0),
                  color: AppColors.pColor.withOpacity(.5),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text(
                                    "Date: ${exam['date']}",
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Day: ${exam['day']}",
                                    style: const TextStyle(
                                      fontSize: 18,

                                    ),
                                  ),
                                  Text(
                                    "Time: ${exam['time_shift']}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 2,),

                        Text(
                          "Class Code: ${exam['class_code']}",
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "Class Title: ${exam['class_title']}",
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "Teacher: ${exam['teacher_name']}",
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(25)),
                                  ),
                                  builder: (BuildContext context) {
                                    return AddOrEditExamRoutineScreen(
                                      exam: exam,
                                    );
                                  },
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await examCollection.doc(exam.id).delete();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class AddOrEditExamRoutineScreen extends StatefulWidget {
  final DocumentSnapshot? exam;

  AddOrEditExamRoutineScreen({this.exam});

  @override
  _AddOrEditExamRoutineScreenState createState() =>
      _AddOrEditExamRoutineScreenState();
}

class _AddOrEditExamRoutineScreenState extends State<AddOrEditExamRoutineScreen> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController dayController = TextEditingController();
  final TextEditingController classCodeController = TextEditingController();
  final TextEditingController classTitleController = TextEditingController();
  final TextEditingController teacherNameController = TextEditingController();
  final TextEditingController timeShiftController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.exam != null) {
      dateController.text = widget.exam!['date'];
      dayController.text = widget.exam!['day'];
      classCodeController.text = widget.exam!['class_code'];
      classTitleController.text = widget.exam!['class_title'];
      teacherNameController.text = widget.exam!['teacher_name'];
      timeShiftController.text = widget.exam!['time_shift'];
    }
  }

  Future<void> _addOrUpdateExamRoutine() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.exam != null) {
        // Update existing exam routine
        await FirebaseFirestore.instance
            .collection('exam_routine')
            .doc(widget.exam!.id)
            .update({
          'date': dateController.text,
          'day': dayController.text,
          'class_code': classCodeController.text,
          'class_title': classTitleController.text,
          'teacher_name': teacherNameController.text,
          'time_shift': timeShiftController.text,
        });
      } else {
        // Add new exam routine
        await FirebaseFirestore.instance.collection('exam_routine').add({
          'date': dateController.text,
          'day': dayController.text,
          'class_code': classCodeController.text,
          'class_title': classTitleController.text,
          'teacher_name': teacherNameController.text,
          'time_shift': timeShiftController.text,
        });
      }

      setState(() {
        _isLoading = false;
      });

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add or update exam routine.")),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
        // Automatically update the day based on the selected date
        dayController.text = _getDayOfWeek(pickedDate);
      });
    }
  }

  String _getDayOfWeek(DateTime date) {
    return ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'][date.weekday - 1];
  }

  Future<void> _selectTimeRange(BuildContext context) async {
    // Select Start Time
    TimeOfDay? pickedStartTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedStartTime != null) {
      // Select End Time
      TimeOfDay? pickedEndTime = await showTimePicker(
        context: context,
        initialTime: pickedStartTime,
      );
      if (pickedEndTime != null) {
        setState(() {
          timeShiftController.text =
          "${pickedStartTime.format(context)} - ${pickedEndTime.format(context)}";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: keyboardHeight + 16.0,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: dateController,
              decoration: AppInputDecoration('Date'),
              readOnly: true,  // Make the field read-only
              onTap: () => _selectDate(context),  // Show date picker on tap
            ),
            const SizedBox(height: 5),
            TextField(
              controller: dayController,
              decoration: AppInputDecoration('Day'),
              readOnly: true,  // Make the field read-only
            ),
            const SizedBox(height: 5),
            TextField(
              controller: classCodeController,
              decoration: AppInputDecoration('Class Code'),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: classTitleController,
              decoration: AppInputDecoration('Class Title'),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: teacherNameController,
              decoration: AppInputDecoration('Teacher Name'),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: timeShiftController,
              decoration: AppInputDecoration('Time Shift'),
              readOnly: true,  // Make the field read-only
              onTap: () => _selectTimeRange(context),  // Show time range picker on tap
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButtonStyle(
              text: widget.exam != null ? 'Update Exam Routine' : 'Add Exam Routine',
              onPressed: () {
                if (dateController.text.isNotEmpty &&
                    dayController.text.isNotEmpty &&
                    classCodeController.text.isNotEmpty &&
                    classTitleController.text.isNotEmpty &&
                    teacherNameController.text.isNotEmpty &&
                    timeShiftController.text.isNotEmpty) {
                  _addOrUpdateExamRoutine();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}


