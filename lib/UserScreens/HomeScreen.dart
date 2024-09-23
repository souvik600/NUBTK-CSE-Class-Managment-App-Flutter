import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nubtk_cse/AdminScreen/AdminPassward.dart';
import 'package:nubtk_cse/UserScreens/ClassRoutineScreen.dart';
import 'package:nubtk_cse/UserScreens/ExamRoutineScreen.dart';
import 'package:nubtk_cse/UserScreens/StudentContactScreen.dart';
import 'package:nubtk_cse/UserScreens/SubjectDetailsScreen.dart';
import 'package:nubtk_cse/UserScreens/TeacherContactScreen.dart';
import '../AppColors/AppColors.dart';
import '../Style/BackgroundStyle.dart';
import '../Utility/Widgets/CatagoriListWidget.dart';
import '../Utility/Widgets/DateTimeWidget.dart';
import '../Utility/Widgets/ImageSlideShowWidget.dart';
import 'ClassNoteScreen.dart';
import 'ClassNoticeScreen.dart';


class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              ScreenBackground(context),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 90,
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const CircleAvatar(
                                radius: 25,
                                backgroundImage:
                                AssetImage("assets/images/cse_logo.jpeg"),
                              ),
                               const Text(
                                "CSE 6A ",
                                style: TextStyle(
                                  color: colorWhite,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'kalpurush',
                                ),
                              ),
                              FilledButton.tonalIcon(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AdminPasswordScreen(),
                                      ));
                                },
                                icon: const Icon(Icons.person_pin,color: Colors.white,),
                                label: const Text('Admin',style: TextStyle(color: Colors.white,fontFamily: 'kalpurush',fontWeight: FontWeight.w600),),
                                style: FilledButton.styleFrom(
                                  backgroundColor:AppColors.pColor.withOpacity(1), // Change this to your desired color
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Container(

                              width: MediaQuery.of(context).size.width,
                              height: 200,
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
                              child: ImageSlideShow()),
                          Container(
                            margin: const EdgeInsets.only(top: 10, bottom: 10),
                            width: MediaQuery.of(context).size.width,
                            height: 95,

                            child: DateTimeWidget(),

                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 25),
                      child: Text(
                        "Categories...",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'kalpurush',
                            color: AppColors.pColor),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      width: MediaQuery.of(context).size.width,
                      child: Column(

                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,

                            children: [
                              CatagoriList(() {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ClassRoutineScreen(),
                                    ));
                              }, "assets/lotti_animation/routine.json", "Class Routine"),
                              const SizedBox(
                                width: 10,
                              ),
                              CatagoriList(() {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SubjectDetailsScreen(),
                                    ));
                              }, "assets/lotti_animation/ditails_note.json", "Subject Details"),
                              const SizedBox(
                                width: 10,
                              ),

                              CatagoriList(() {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ClassNoteScreen(),
                                    ));
                              }, "assets/lotti_animation/note.json", "Class Note"),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              CatagoriList(() {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ClassNoticeScreen(),
                                    ));
                              }, "assets/lotti_animation/calender.json", "Notice"),
                              const SizedBox(
                                width: 10,
                              ),
                              CatagoriList(() {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StudentContactScreen(),
                                    ));
                              }, "assets/lotti_animation/call.json", "Student Contact"),
                              const SizedBox(
                                width: 10,
                              ),
                              CatagoriList(() {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TeacherContactScreen(),
                                    ));
                              }, "assets/lotti_animation/call_center_support.json", "Teacher Contact"),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5,left: 16),
                      child: Row(
                        children: [
                          Text("Exam Routine :   ",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 18,fontFamily: 'kalpurush',),),
                          FilledButton.tonalIcon(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ExamRoutineScreen(),
                                  ));

                            },
                            icon: const Icon(Icons.event_note_outlined),
                            label: const Text('Exam Routine'),
                            style: FilledButton.styleFrom(
                              backgroundColor:AppColors.rColor.withOpacity(.6), // Change this to your desired color
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
