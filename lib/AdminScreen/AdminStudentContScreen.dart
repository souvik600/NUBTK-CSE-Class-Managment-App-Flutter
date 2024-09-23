import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:nubtk_cse/Style/CustomAppBar.dart';
import '../AppColors/AppColors.dart';
import '../Style/BottonStyle.dart';
import '../Style/InputDecorationStyle.dart';

class AdminStudentContactScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarStyle('Student Contact'),
      body: StudentContactClass(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            builder: (BuildContext context) {
              return AddStudentScreen();
            },
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: AppColors.spColor,
      ),
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
                                    const SizedBox(width: 10),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        _deleteStudent(student.id, student['imagePath']);
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      label: const Text("Delete"),
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
                                        return EditStudentScreen(student: student);
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

  void _makePhoneCall(String phoneNumber) {
    AndroidIntent intent = AndroidIntent(
      action: 'action_view',
      data: 'tel:$phoneNumber',
    );
    intent.launch();
  }

  Future<void> _deleteStudent(String studentId, String? imagePath) async {
    try {
      await studentCollection.doc(studentId).delete();
      if (imagePath != null) {
        final storageRef = FirebaseStorage.instance.refFromURL(imagePath);
        await storageRef.delete();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Student deleted successfully.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete student.")),
      );
    }
  }
}

class AddStudentScreen extends StatefulWidget {
  @override
  _AddStudentScreenState createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController idController = TextEditingController();
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
          .child('student_images/${DateTime.now().millisecondsSinceEpoch}.png');
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
              controller: phoneController,
              decoration: AppInputDecoration('Phone Number'),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: idController,
              decoration: AppInputDecoration('ID'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButtonStyle(
              text: 'Add Student',
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    designationController.text.isNotEmpty &&
                    phoneController.text.isNotEmpty &&
                    idController.text.isNotEmpty) {
                  setState(() {
                    _isLoading = true;
                  });

                  String? imageUrl;
                  if (_image != null) {
                    imageUrl = await _uploadImageToFirebase();
                  }

                  await FirebaseFirestore.instance.collection('students').add({
                    'name': nameController.text,
                    'designation': designationController.text,
                    'phone_no': phoneController.text,
                    'id': idController.text,
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

class EditStudentScreen extends StatefulWidget {
  final QueryDocumentSnapshot student;

  EditStudentScreen({required this.student});

  @override
  _EditStudentScreenState createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.student['name'];
    designationController.text = widget.student['designation'];
    phoneController.text = widget.student['phone_no'];
    idController.text = widget.student['id'];
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
          .child('student_images/${DateTime.now().millisecondsSinceEpoch}.png');
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
              controller: phoneController,
              decoration: AppInputDecoration('Phone Number'),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: idController,
              decoration: AppInputDecoration('ID'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButtonStyle(
              text: 'Update Student',
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    designationController.text.isNotEmpty &&
                    phoneController.text.isNotEmpty &&
                    idController.text.isNotEmpty) {
                  setState(() {
                    _isLoading = true;
                  });

                  String? imageUrl;
                  if (_image != null) {
                    imageUrl = await _uploadImageToFirebase();
                  } else {
                    imageUrl = widget.student['imagePath'];
                  }

                  await FirebaseFirestore.instance.collection('students').doc(widget.student.id).update({
                    'name': nameController.text,
                    'designation': designationController.text,
                    'phone_no': phoneController.text,
                    'id': idController.text,
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
