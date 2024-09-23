import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../AppColors/AppColors.dart';
import '../Style/BackgroundStyle.dart';


class Note {
  final String title;
  final String description;
  final DateTime dateTime;

  Note({
    required this.title,
    required this.description,
    required this.dateTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      title: json['title'],
      description: json['description'],
      dateTime: DateTime.parse(json['dateTime']),
    );
  }
}

class ClassNoteScreen extends StatefulWidget {
  @override
  _ClassNoteScreenState createState() => _ClassNoteScreenState();
}

class _ClassNoteScreenState extends State<ClassNoteScreen> {
  final List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  String formatDateWithDay(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime).inDays;

    if (difference <= 7) {
      return DateFormat(' HH:mm  EEEE ')
          .format(dateTime); // Show day if within a week
    } else {
      return DateFormat('HH:mm  dd-MM-yyyy')
          .format(dateTime); // Show date if more than a week
    }
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesData = prefs.getStringList('notes');
    if (notesData != null) {
      setState(() {
        _notes.clear();
        _notes.addAll(
            notesData.map((noteJson) => Note.fromJson(jsonDecode(noteJson))));
      });
    }
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = _notes.map((note) => jsonEncode(note.toJson())).toList();
    await prefs.setStringList('notes', notesJson);
  }

  void _addNote(String title, String description) {
    setState(() {
      _notes.add(Note(
        title: title,
        description: description,
        dateTime: DateTime.now(),
      ));
    });
    _saveNotes();
  }

  void _deleteNote(int index) {
    setState(() {
      _notes.removeAt(index);
    });
    _saveNotes();
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
                              backgroundImage:
                              AssetImage("assets/images/cse_logo.jpeg"),
                            ),
                            Text(
                              "Class Note",
                              style: TextStyle(
                                color:colorWhite,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Icon(
                              Icons.notifications_outlined,
                              color: colorWhite,
                              size: 30,
                            )
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height -
                              160, // Adjusted height for notes list
                          child: ListView.builder(
                            itemCount: _notes.length,
                            itemBuilder: (context, index) {
                              final note = _notes[index];
                              return Card(
                                color: Colors.white54,
                                child: ListTile(
                                  title: Center(
                                      child: Text(
                                        note.title,
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.spColor),
                                      )),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        note.description,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87),
                                      ),
                                      Text(
                                        formatDateWithDay(note.dateTime),
                                        // Using the function to format date
                                        style: const TextStyle(
                                            color: Colors.black38,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete,color: colorRed,),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            //backgroundColor: Colors.transparent,
                                            title: const Text(
                                                "You want to delete!!"),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop();
                                                },
                                                child: const Text('No'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  _deleteNote(index);
                                                  Navigator.of(context)
                                                      .pop();
                                                },
                                                child: const Text('Yes'),
                                              ),
                                            ],
                                          ));
                                    },
                                    // onPressed: () => _deleteNote(index),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              String title = '';
                              String description = '';
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Add Note'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        decoration: const InputDecoration(
                                            labelText: 'Title',
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10)))),
                                        onChanged: (value) => title = value,
                                      ),
                                      const SizedBox(height: 8.0),
                                      TextField(
                                        decoration: const InputDecoration(
                                            labelText: 'Description',
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(10),
                                                ))),
                                        onChanged: (value) =>
                                        description = value,
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
                                        _addNote(title, description);
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Add'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: AppColors.pColor,
                              // Text color
                              padding: const EdgeInsets.only(
                                  left: 120, right: 120, bottom: 10, top: 10),
                              // Button padding
                              textStyle: const TextStyle(
                                fontSize: 20, // Text size
                              ),
                            ),
                            child: const Text('Add Note'),
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
