import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart'; // For clipboard functionality
import 'package:url_launcher/url_launcher.dart';
import '../AppColors/AppColors.dart';
import '../Style/CustomAppBar.dart';
import '../Style/BottonStyle.dart';
import '../Style/InputDecorationStyle.dart';

class SubjectDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarStyle('Subject Details'),
      body: SubjectDetailsClass(),
    );
  }
}

class SubjectDetailsClass extends StatefulWidget {
  @override
  _SubjectDetailsClassState createState() => _SubjectDetailsClassState();
}

class _SubjectDetailsClassState extends State<SubjectDetailsClass> {
  final CollectionReference subjectCollection =
  FirebaseFirestore.instance.collection('subjects');
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search here',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
        ),
        Expanded(
          child: StreamBuilder(
            stream: subjectCollection.snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.purple));
              }

              final subjects = snapshot.data?.docs ?? [];

              final filteredSubjects = subjects.where((subject) {
                final courseCode = subject['course_code'].toString().toLowerCase();
                return courseCode.contains(_searchQuery);
              }).toList();

              return ListView.builder(
                itemCount: filteredSubjects.length,
                itemBuilder: (context, index) {
                  final subject = filteredSubjects[index];
                  return Card(
                    elevation: 2.0,
                    margin: const EdgeInsets.all(5.0),
                    color: AppColors.pColor.withOpacity(.5),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8.0),
                              bottomLeft: Radius.circular(8.0),
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: subject['image_url'] != null
                                  ? NetworkImage(subject['image_url'])
                                  : const AssetImage('assets/images/default_profile.png')
                              as ImageProvider,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 8, bottom: 5, right: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Text(
                                            subject['course_code'],
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontFamily: 'kalpurush',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          subject['course_name'],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'kalpurush',
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Teacher: ${subject['teacher_name']}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'kalpurush',
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600
                                  ),
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(
                                        text: subject['classroom_code']));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text("Classroom code copied to clipboard.")),
                                    );
                                  },
                                  child: Text(
                                    "Classroom: ${subject['classroom_code']}",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'kalpurush',
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.underline,
                                      color: Colors.brown,
                                    ),
                                  ),
                                ),
                                subject['course_outline'] != null &&
                                    subject['course_outline'].isNotEmpty
                                    ? ElevatedButton.icon(
                                  onPressed: () async {
                                    final url = subject['course_outline'];
                                    if (await canLaunch(url)) {
                                      await launch(url);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "Cannot open course outline URL."),
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.link,
                                    color: Colors.green,
                                  ),
                                  label: const Text("Course Outline"),
                                )
                                    : const Text(
                                  "No course outline available",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.red,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

}

