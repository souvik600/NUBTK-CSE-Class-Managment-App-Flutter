import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../AppColors/AppColors.dart';
import '../Style/BackgroundStyle.dart';

class Notice {
  final String title;
  final String description;
  final DateTime dateTime;

  Notice({
    required this.title,
    required this.description,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  factory Notice.fromMap(Map<String, dynamic> map) {
    return Notice(
      title: map['title'],
      description: map['description'],
      dateTime: DateTime.parse(map['dateTime']),
    );
  }
}

class ClassNoticeScreen extends StatefulWidget {
  @override
  _ClassNoticeScreenState createState() => _ClassNoticeScreenState();
}

class _ClassNoticeScreenState extends State<ClassNoticeScreen> {
  final List<Notice> _notices = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNoticesFromFirestore();
  }

  String formatDateWithDay(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime).inDays;

    if (difference <= 7) {
      return DateFormat('HH:mm EEEE').format(dateTime); // Show day if within a week
    } else {
      return DateFormat('HH:mm dd-MM-yyyy').format(dateTime); // Show date if more than a week
    }
  }

  Future<void> _loadNoticesFromFirestore() async {
    final noticeSnapshot = await FirebaseFirestore.instance.collection('notice').get();
    setState(() {
      _notices.clear();
      _notices.addAll(
          noticeSnapshot.docs.map((doc) => Notice.fromMap(doc.data())).toList());
    });
  }

  Future<void> _addNoticeToFirestore(Notice notice) async {
    await FirebaseFirestore.instance.collection('notice').add(notice.toMap());
    _loadNoticesFromFirestore(); // Refresh notes after adding
  }

  void _addNotice() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Notice'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)))),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)))),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final title = _titleController.text;
              final description = _descriptionController.text;

              if (title.isNotEmpty && description.isNotEmpty) {
                final notice = Notice(
                  title: title,
                  description: description,
                  dateTime: DateTime.now(),
                );
                _addNoticeToFirestore(notice);
                _titleController.clear();
                _descriptionController.clear();
                Navigator.of(context).pop();
              } else {
                // Show an error message if fields are empty
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter both title and description')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            ScreenBackground(context),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 95,
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
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: AssetImage("assets/images/cse_logo.jpeg"),
                            ),
                            Text(
                              "Class Notice",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Icon(
                              Icons.notifications_outlined,
                              color: Colors.white,
                              size: 30,
                            )
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height - 160,
                          child: ListView.builder(
                            itemCount: _notices.length,
                            itemBuilder: (context, index) {
                              final notice = _notices[index];
                              return Card(
                                color: Colors.white54,
                                child: ListTile(
                                  title: Center(
                                    child: Text(
                                      notice.title,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.spColor,
                                      ),
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        notice.description,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        formatDateWithDay(notice.dateTime),
                                        style: const TextStyle(
                                            color: Colors.black38,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: _addNotice,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: AppColors.pColor,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 110),
                              textStyle: const TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            child: const Text('Add Notice'),
                          ),
                        ),
                      ],
                    ),
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
