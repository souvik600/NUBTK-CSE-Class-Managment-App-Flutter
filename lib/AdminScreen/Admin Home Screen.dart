import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nubtk_cse/AdminScreen/AdminExamRoutineScreen.dart';
import 'package:nubtk_cse/AdminScreen/AdminSubjectDetailsScreen.dart';
import '../AppColors/AppColors.dart';
import '../Style/BackgroundStyle.dart';
import '../Utility/Widgets/CatagoriListWidget.dart';
import 'AdminClassRoutineScreen.dart';
import 'AdminStudentContScreen.dart';
import 'AdminTeacherContScreen.dart';

class AdminHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              ScreenBackground(context),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 100,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.pColor.withOpacity(0.8),
                        AppColors.pColor,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(onPressed: (){
                                Navigator.pop(context);
                              }, icon: const Icon(Icons.arrow_back_ios,color: colorWhite,)),
                              const CircleAvatar(
                                radius: 25,
                                backgroundImage:
                                AssetImage("assets/images/cse_logo.jpeg"),
                              ),
                              const SizedBox(width: 20,),
                              const Text(
                                "Admin Panel",
                                style: TextStyle(
                                  color: colorWhite,
                                  fontFamily: 'kalpurush',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Center(child: SizedBox(height: 100)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: colorLight,
                          boxShadow:[
                            BoxShadow(blurRadius: 5.0,color: colorDarkBlue)
                          ] ,
                          borderRadius: BorderRadius.all(Radius.circular(10)),

                        ),

                        padding: const EdgeInsets.all(20),
                        width: MediaQuery.of(context).size.width,
                        child: Column(

                          children: [
                            const Text(
                              "Categories...",
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'kalpurush',
                                  color: AppColors.pColor),
                            ),
                            const SizedBox(height: 25,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,

                              children: [
                                CatagoriList(() {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const AdminClassRoutineScreen(),
                                      ));
                                }, "assets/lotti_animation/routine.json", "Class Routine"),

                                CatagoriList(() {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AdminSubjectDetailsScreen(),
                                      ));
                                }, "assets/lotti_animation/ditails_note.json", "Subject Details"),

                              ],
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                CatagoriList(() {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AdminStudentContactScreen(),
                                      ));
                                }, "assets/lotti_animation/call.json", "Student Contact"),
                                CatagoriList(() {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AdminTeacherContactScreen(),
                                      ));
                                }, "assets/lotti_animation/call_center_support.json", "Teacher Contact"),
                              ],
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                CatagoriList(() {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AdminExamRoutineScreen(),
                                      ));
                                }, "assets/lotti_animation/note.json", "Exam Routine"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
    );
  }
}
