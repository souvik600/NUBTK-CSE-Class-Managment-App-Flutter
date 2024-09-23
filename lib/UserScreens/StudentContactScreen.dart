import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:nubtk_cse/Style/CustomAppBar.dart';
import '../AppColors/AppColors.dart';

class StudentContactScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarStyle('Student Contact'),
      body: StudentContactClass(),
    );
  }
}

class StudentContactClass extends StatefulWidget {
  @override
  _StudentContactClassState createState() => _StudentContactClassState();
}

class _StudentContactClassState extends State<StudentContactClass> {
  final CollectionReference studentCollection =
  FirebaseFirestore.instance.collection('students');
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
            stream: studentCollection.snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.purple));
              }

              final students = snapshot.data?.docs ?? [];

              final filteredStudents = students.where((student) {
                final name = student['name'].toString().toLowerCase();
                return name.contains(_searchQuery);
              }).toList();

              return ListView.builder(
                itemCount: filteredStudents.length,
                itemBuilder: (context, index) {
                  final student = filteredStudents[index];
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
                              backgroundImage: student['imagePath'] != null
                                  ? NetworkImage(student['imagePath'])
                                  : const AssetImage('assets/images/default_profile.png')
                              as ImageProvider,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 5, right: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 5, right: 5),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          student['name'],
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontFamily: 'kalpurush',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          student['designation'],
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
                                Row(
                                  children: [
                                    const Text(
                                      'ID : ',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: 'kalpurush',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      student['id'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontFamily: 'kalpurush',
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.spColor,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Cont. No : ',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: 'kalpurush',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      student['phone_no'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontFamily: 'kalpurush',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        _makePhoneCall(student['phone_no']);
                                      },
                                      icon: const Icon(
                                        Icons.call,
                                        color: Colors.green,
                                      ),
                                      label: const Text("Call", style: TextStyle(fontFamily: 'kalpurush', fontWeight: FontWeight.w600)),
                                    ),

                                  ],
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

  void _makePhoneCall(String phoneNumber) {
    AndroidIntent intent = AndroidIntent(
      action: 'action_view',
      data: 'tel:$phoneNumber',
    );
    intent.launch();
  }
}
