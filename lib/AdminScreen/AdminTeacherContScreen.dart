import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nubtk_cse/Style/CustomAppBar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../AppColors/AppColors.dart';
import '../Style/BottonStyle.dart';
import '../Style/InputDecorationStyle.dart';

class AdminTeacherContactScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarStyle('Teacher Contact'),
      body: TeacherContactClass(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            builder: (BuildContext context) {
              return AddTeacherScreen();
            },
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: AppColors.spColor,
      ),
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
                                    const SizedBox(width: 10),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        _deleteTeacher(teacher.id, teacher['imagePath']);
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      label: const Text(""),
                                    ),

                                  ],
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                                      ),
                                      builder: (BuildContext context) {
                                        return EditTeacherScreen(teacher: teacher,);
                                      },
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  label: const Text("Edit"),
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

  Future<void> _deleteTeacher(String teacherId, String? imagePath) async {
    try {
      await teacherCollection.doc(teacherId).delete();
      if (imagePath != null) {
        final storageRef = FirebaseStorage.instance.refFromURL(imagePath);
        await storageRef.delete();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Teacher deleted successfully.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete student.")),
      );
    }
  }
}

class AddTeacherScreen extends StatefulWidget {
  @override
  _AddTeacherScreenState createState() => _AddTeacherScreenState();
}

class _AddTeacherScreenState extends State<AddTeacherScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Image selection error: $e");
    }
  }

  Future<String?> _uploadImageToFirebase() async {
    if (_image == null) return null;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('teacher_images/${DateTime.now().millisecondsSinceEpoch}.png');
      final uploadTask = storageRef.putFile(_image!);
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Image upload error: $e");
      return null;
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
            Stack(
              alignment: Alignment.center,
              children: [
                _image == null
                    ? CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  child: const Icon(Icons.person, size: 50, color: Colors.grey),
                )
                    : CircleAvatar(
                  radius: 75,
                  backgroundImage: FileImage(_image!),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: FloatingActionButton(
                      onPressed: _pickImage,
                      child: const Icon(Icons.camera_alt, size: 20),
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: AppInputDecoration('Name'),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: designationController,
              decoration: AppInputDecoration('Designation'),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: emailController,
              decoration: AppInputDecoration('Email'),
            ),

            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButtonStyle(
              text: 'Add Teacher',
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    designationController.text.isNotEmpty &&
                    emailController.text.isNotEmpty) {
                  setState(() {
                    _isLoading = true;
                  });

                  String? imageUrl;
                  if (_image != null) {
                    imageUrl = await _uploadImageToFirebase();
                  }

                  await FirebaseFirestore.instance.collection('teachers').add({
                    'name': nameController.text,
                    'designation': designationController.text,
                    'email': emailController.text,
                    'imagePath': imageUrl,
                  });
                  Navigator.pop(context);
                  setState(() {
                    _isLoading = false;
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("All fields are required."),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class EditTeacherScreen extends StatefulWidget {
  final QueryDocumentSnapshot teacher;

  EditTeacherScreen({required this.teacher});

  @override
  _EditTeacherScreenState createState() => _EditTeacherScreenState();
}

class _EditTeacherScreenState extends State<EditTeacherScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.teacher['name'];
    designationController.text = widget.teacher['designation'];
    emailController.text = widget.teacher['email'];
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Image selection error: $e");
    }
  }

  Future<String?> _uploadImageToFirebase() async {
    if (_image == null) return null;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('teacher_images/${DateTime.now().millisecondsSinceEpoch}.png');
      final uploadTask = storageRef.putFile(_image!);
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Image upload error: $e");
      return null;
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
            Stack(
              alignment: Alignment.center,
              children: [
                _image == null
                    ? CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  child: const Icon(Icons.person, size: 50, color: Colors.grey),
                )
                    : CircleAvatar(
                  radius: 75,
                  backgroundImage: FileImage(_image!),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: FloatingActionButton(
                      onPressed: _pickImage,
                      child: const Icon(Icons.camera_alt, size: 20),
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: AppInputDecoration('Name'),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: designationController,
              decoration: AppInputDecoration('Designation'),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: emailController,
              decoration: AppInputDecoration('Email'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButtonStyle(
              text: 'Update Teacher',
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    designationController.text.isNotEmpty &&
                    emailController.text.isNotEmpty ) {
                  setState(() {
                    _isLoading = true;
                  });

                  String? imageUrl;
                  if (_image != null) {
                    imageUrl = await _uploadImageToFirebase();
                  } else {
                    imageUrl = widget.teacher['imagePath'];
                  }

                  await FirebaseFirestore.instance.collection('teachers').doc(widget.teacher.id).update({
                    'name': nameController.text,
                    'designation': designationController.text,
                    'email': emailController.text,
                    'imagePath': imageUrl,
                  });
                  Navigator.pop(context);
                  setState(() {
                    _isLoading = false;
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("All fields are required."),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
