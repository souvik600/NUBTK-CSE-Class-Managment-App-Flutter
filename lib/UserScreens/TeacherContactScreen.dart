import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nubtk_cse/Style/CustomAppBar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../AppColors/AppColors.dart';

class TeacherContactScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarStyle('Teacher Contact'),
      body: TeacherContactClass(),
    );
  }
}

class TeacherContactClass extends StatefulWidget {
  @override
  _TeacherContactClassState createState() => _TeacherContactClassState();
}

class _TeacherContactClassState extends State<TeacherContactClass> {
  final CollectionReference teacherCollection =
  FirebaseFirestore.instance.collection('teachers');
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
            stream: teacherCollection.snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.purple));
              }

              final students = snapshot.data?.docs ?? [];

              final filteredTeachers = students.where((teacher) {
                final name = teacher['name'].toString().toLowerCase();
                return name.contains(_searchQuery);
              }).toList();

              return ListView.builder(
                itemCount: filteredTeachers.length,
                itemBuilder: (context, index) {
                  final teacher = filteredTeachers[index];
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
                              backgroundImage: teacher['imagePath'] != null
                                  ? NetworkImage(teacher['imagePath'])
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
                                          teacher['name'],
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontFamily: 'kalpurush',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          teacher['designation'],
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
                                  teacher['email'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'kalpurush',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        _sendEmail(teacher['email']);
                                      },
                                      icon: const Icon(
                                        Icons.mail_outline,
                                        color: Colors.red,
                                      ),
                                      label: const Text("Email", style: TextStyle(fontFamily: 'kalpurush', fontWeight: FontWeight.w600)),
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

  void _sendEmail(String email) async {
    // For Android, use the Gmail app's package name
    final String gmailUrl = 'googlegmail:///co?to=$email';

    if (await canLaunch(gmailUrl)) {
      await launch(gmailUrl);
    } else {
      // If the Gmail app is not found, try launching the email client
      final Uri _emailLaunchUri = Uri(
        scheme: 'mailto',
        path: email,
      );

      if (await canLaunch(_emailLaunchUri.toString())) {
        await launch(_emailLaunchUri.toString());
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('No email app found.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

}


