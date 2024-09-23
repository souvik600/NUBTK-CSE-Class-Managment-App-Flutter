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

class AdminSubjectDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarStyle('Subject Details'),
      body: SubjectDetailsClass(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            builder: (BuildContext context) {
              return AddSubjectScreen();
            },
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: AppColors.spColor,
      ),
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
                                        Text(
                                          subject['course_code'],
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontFamily: 'kalpurush',
                                            fontWeight: FontWeight.bold,
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
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(25)),
                                          ),
                                          builder: (BuildContext context) {
                                            return EditSubjectScreen(
                                              subject: subject,
                                            );
                                          },
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      label: const Text("Edit"),
                                    ),
                                    SizedBox(width: 5,),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        _deleteSubject(subject.id);
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      label: const Text("Delete"),
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

  Future<void> _deleteSubject(String subjectId) async {
    try {
      await subjectCollection.doc(subjectId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Subject deleted successfully.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete subject.")),
      );
    }
  }
}

class AddSubjectScreen extends StatefulWidget {
  @override
  _AddSubjectScreenState createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen> {
  final TextEditingController courseCodeController = TextEditingController();
  final TextEditingController courseNameController = TextEditingController();
  final TextEditingController teacherNameController = TextEditingController();
  final TextEditingController classroomCodeController = TextEditingController();
  final TextEditingController courseOutlineController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImageAndSaveSubject() async {
    if (_imageFile != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('subject_images/${DateTime.now().toIso8601String()}');
        await storageRef.putFile(_imageFile!);
        final imageUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance.collection('subjects').add({
          'course_code': courseCodeController.text,
          'course_name': courseNameController.text,
          'teacher_name': teacherNameController.text,
          'classroom_code': classroomCodeController.text,
          'course_outline': courseOutlineController.text,
          'image_url': imageUrl,
        });

        setState(() {
          _isLoading = false;
        });

        Navigator.pop(context);
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to add subject.")),
        );
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
              controller: courseCodeController,
              decoration: AppInputDecoration('Course Code'),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: courseNameController,
              decoration: AppInputDecoration('Course Name'),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: teacherNameController,
              decoration: AppInputDecoration('Teacher Name'),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: classroomCodeController,
              decoration: AppInputDecoration('Classroom Code'),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: courseOutlineController,
              decoration: AppInputDecoration('Course Outline URL'),
            ),
            const SizedBox(height: 10),
            _imageFile != null
                ? Image.file(
              _imageFile!,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            )
                : const Text("No image selected"),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButtonStyle(
              text: 'Add Subject',
              onPressed: () {
                if (courseCodeController.text.isNotEmpty &&
                    courseNameController.text.isNotEmpty &&
                    teacherNameController.text.isNotEmpty &&
                    classroomCodeController.text.isNotEmpty &&
                    courseOutlineController.text.isNotEmpty) {
                  _uploadImageAndSaveSubject();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class EditSubjectScreen extends StatefulWidget {
  final DocumentSnapshot subject;

  EditSubjectScreen({required this.subject});

  @override
  _EditSubjectScreenState createState() => _EditSubjectScreenState();
}

class _EditSubjectScreenState extends State<EditSubjectScreen> {
  final TextEditingController courseCodeController = TextEditingController();
  final TextEditingController courseNameController = TextEditingController();
  final TextEditingController teacherNameController = TextEditingController();
  final TextEditingController classroomCodeController = TextEditingController();
  final TextEditingController courseOutlineController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    courseCodeController.text = widget.subject['course_code'];
    courseNameController.text = widget.subject['course_name'];
    teacherNameController.text = widget.subject['teacher_name'];
    classroomCodeController.text = widget.subject['classroom_code'];
    courseOutlineController.text = widget.subject['course_outline'];
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImageAndUpdateSubject() async {
    if (_imageFile != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('subject_images/${DateTime.now().toIso8601String()}');
        await storageRef.putFile(_imageFile!);
        final imageUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance.collection('subjects').doc(widget.subject.id).update({
          'course_code': courseCodeController.text,
          'course_name': courseNameController.text,
          'teacher_name': teacherNameController.text,
          'classroom_code': classroomCodeController.text,
          'course_outline': courseOutlineController.text,
          'image_url': imageUrl,
        });

        setState(() {
          _isLoading = false;
        });

        Navigator.pop(context);
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update subject.")),
        );
      }
    } else {
      await FirebaseFirestore.instance.collection('subjects').doc(widget.subject.id).update({
        'course_code': courseCodeController.text,
        'course_name': courseNameController.text,
        'teacher_name': teacherNameController.text,
        'classroom_code': classroomCodeController.text,
        'course_outline': courseOutlineController.text,
      });

      Navigator.pop(context);
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
              controller: courseCodeController,
              decoration: AppInputDecoration('Course Code'),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: courseNameController,
              decoration: AppInputDecoration('Course Name'),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: teacherNameController,
              decoration: AppInputDecoration('Teacher Name'),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: classroomCodeController,
              decoration: AppInputDecoration('Classroom Code'),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: courseOutlineController,
              decoration: AppInputDecoration('Course Outline URL'),
            ),
            const SizedBox(height: 10),
            _imageFile != null
                ? Image.file(
              _imageFile!,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            )
                : widget.subject['image_url'] != null
                ? Image.network(
              widget.subject['image_url'],
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            )
                : const Text("No image selected"),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButtonStyle(
              text: 'Update Subject',
              onPressed: () {
                if (courseCodeController.text.isNotEmpty &&
                    courseNameController.text.isNotEmpty &&
                    teacherNameController.text.isNotEmpty &&
                    classroomCodeController.text.isNotEmpty &&
                    courseOutlineController.text.isNotEmpty) {
                  _uploadImageAndUpdateSubject();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
