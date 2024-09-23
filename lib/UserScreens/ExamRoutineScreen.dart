import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../AppColors/AppColors.dart';
import '../Style/BackgroundStyle.dart';
import '../Style/CustomAppBar.dart';
import '../Utility/Widgets/DateTimeWidget.dart';

class ExamRoutineScreen extends StatelessWidget {
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



