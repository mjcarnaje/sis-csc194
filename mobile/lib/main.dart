import 'dart:convert';
import 'dart:developer' as logger;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Student Information System'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Center(
            child: Column(
              children: [
                const Text(
                  "Student Information System",
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: Builder(
                    builder: (context) => ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CoursesPage()));
                      },
                      child: const Text('Courses'),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: Builder(
                    builder: (context) => ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const StudentsPage()));
                      },
                      child: const Text('Students'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const String apiUrl = '127.0.0.1:5000';

class Course {
  final String courseName;
  final String courseId;

  Course({required this.courseName, required this.courseId});

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      courseName: json['course_name'],
      courseId: json['course_id'].toString(),
    );
  }
}

class CoursesPage extends StatefulWidget {
  const CoursesPage({
    super.key,
  });

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  static Future<List<Course>> getCourses() async {
    logger.log('Fetching courses from API');
    final response = await http.get(Uri.http(apiUrl, '/courses'), headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      logger.log('Response body: $body');
      if (body is Map<String, dynamic> && body['Message'] is List) {
        final List<dynamic> messages = body['Message'];
        return messages.map<Course>((json) => Course.fromJson(json)).toList();
      } else {
        throw Exception('Failed to parse courses from API');
      }
    } else {
      throw Exception(
          'Failed to load courses from API with status code ${response.statusCode}');
    }
  }

  Future<List<Course>> coursesFuture = getCourses();

  Future<void> refreshCourses() async {
    setState(() {
      coursesFuture = getCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddCoursePage(
                                  refreshCourses: refreshCourses,
                                )));
                  },
                  child: const Text('Add Course'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Courses',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    )),
                ElevatedButton(
                    onPressed: () {
                      refreshCourses();
                    },
                    child: const Text('Refresh')),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                FutureBuilder<List<Course>>(
                  future: coursesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.connectionState !=
                        ConnectionState.done) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      return ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  snapshot.data![index].courseName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    EditCoursePage(
                                                        course: snapshot
                                                            .data![index],
                                                        refreshCourses:
                                                            refreshCourses)));
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: const CircleBorder(),
                                        padding: const EdgeInsets.all(10),
                                      ),
                                      child: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                        size: 24.0,
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title:
                                                  const Text('Delete Course'),
                                              content: const Text(
                                                  'Are you sure you want to delete this course?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    http
                                                        .delete(Uri.http(apiUrl,
                                                            '/course/${snapshot.data![index].courseId}'))
                                                        .then((response) {
                                                      if (response.statusCode ==
                                                          200) {
                                                        setState(() {
                                                          coursesFuture =
                                                              getCourses();
                                                        });
                                                        Navigator.pop(context);
                                                      } else {
                                                        throw Exception(
                                                            'Failed to delete course with status code ${response.statusCode}');
                                                      }
                                                    });
                                                  },
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: const CircleBorder(),
                                        padding: const EdgeInsets.all(10),
                                      ),
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 24.0,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class AddCoursePage extends StatefulWidget {
  final Function refreshCourses;

  const AddCoursePage({super.key, required this.refreshCourses});

  @override
  State<AddCoursePage> createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  TextEditingController courseNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Course'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: courseNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Course Name',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                http
                    .post(Uri.http(apiUrl, '/course'),
                        headers: {
                          'Content-Type': 'application/json',
                        },
                        body: json.encode({
                          'course': courseNameController.text,
                        }))
                    .then((response) {
                  if (response.statusCode == 200) {
                    widget.refreshCourses();
                    Navigator.pop(context);
                  } else {
                    throw Exception(
                        'Failed to add course with status code ${response.statusCode}');
                  }
                });
              },
              child: const Text('Add Course'),
            ),
          ],
        ),
      ),
    );
  }
}

class EditCoursePage extends StatefulWidget {
  final Course course;
  final Function refreshCourses;

  const EditCoursePage(
      {super.key, required this.course, required this.refreshCourses});

  @override
  State<EditCoursePage> createState() => _EditCoursePageState();
}

class _EditCoursePageState extends State<EditCoursePage> {
  TextEditingController courseNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    courseNameController.text = widget.course.courseName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Course'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: courseNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Course Name',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                http
                    .put(Uri.http(apiUrl, '/course/${widget.course.courseId}'),
                        headers: {
                          'Content-Type': 'application/json',
                        },
                        body: json.encode({
                          'course': courseNameController.text,
                        }))
                    .then((response) {
                  if (response.statusCode == 200) {
                    widget.refreshCourses();
                    Navigator.pop(context);
                  } else {
                    throw Exception(
                        'Failed to update course with status code ${response.statusCode}');
                  }
                });
              },
              child: const Text('Update Course'),
            ),
          ],
        ),
      ),
    );
  }
}

class Student {
  final String studentId;
  final String studentName;
  final String courseName;

  Student(
      {required this.studentId,
      required this.studentName,
      required this.courseName});

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: json['student_id'].toString(),
      studentName: json['student_name'],
      courseName: json['course_name'],
    );
  }
}

class StudentsPage extends StatefulWidget {
  const StudentsPage({
    super.key,
  });

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  static Future<List<Student>> getStudents() async {
    logger.log('Fetching courses from API');
    final response = await http.get(Uri.http(apiUrl, '/students'), headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      logger.log('Response body: $body');
      if (body is Map<String, dynamic>) {
        final List<dynamic> messages = body['Message'] ?? [];
        return messages.map<Student>((json) => Student.fromJson(json)).toList();
      } else {
        throw Exception('Failed to parse students from API');
      }
    } else {
      throw Exception(
          'Failed to load students from API with status code ${response.statusCode}');
    }
  }

  Future<List<Student>> studentsFuture = getStudents();

  Future<void> refreshStudents() async {
    setState(() {
      studentsFuture = getStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddCoursePage(
                                  refreshCourses: refreshStudents,
                                )));
                  },
                  child: const Text('Add Student'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Courses',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    )),
                ElevatedButton(
                    onPressed: () {
                      refreshStudents();
                    },
                    child: const Text('Refresh')),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                FutureBuilder<List<Student>>(
                  future: studentsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.connectionState !=
                        ConnectionState.done) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      if (snapshot.data!.isEmpty) {
                        return const Text('No students found');
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          snapshot.data![index].studentName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          snapshot.data![index].courseName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )
                                      ]),
                                ),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        shape: const CircleBorder(),
                                        padding: const EdgeInsets.all(10),
                                      ),
                                      child: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                        size: 24.0,
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title:
                                                  const Text('Delete Student'),
                                              content: const Text(
                                                  'Are you sure you want to delete this student?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    http
                                                        .delete(Uri.http(apiUrl,
                                                            '/student/${snapshot.data![index].studentId}'))
                                                        .then((response) {
                                                      if (response.statusCode ==
                                                          200) {
                                                        refreshStudents();
                                                        Navigator.pop(context);
                                                      } else {
                                                        throw Exception(
                                                            'Failed to delete student with status code ${response.statusCode}');
                                                      }
                                                    });
                                                  },
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: const CircleBorder(),
                                        padding: const EdgeInsets.all(10),
                                      ),
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 24.0,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      );
                    } else {
                      return const Text('No students found');
                    }
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class AddStudentPage extends StatefulWidget {
  final Function refreshStudents;

  const AddStudentPage({super.key, required this.refreshStudents});

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  TextEditingController studentNameController = TextEditingController();
  TextEditingController courseIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Student'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: studentNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Student Name',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: courseIdController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Course ID',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                http
                    .post(Uri.http(apiUrl, '/student'),
                        headers: {
                          'Content-Type': 'application/json',
                        },
                        body: json.encode({
                          'student_name': studentNameController.text,
                          'course_id': courseIdController.text,
                        }))
                    .then((response) {
                  if (response.statusCode == 200) {
                    widget.refreshStudents();
                    Navigator.pop(context);
                  } else {
                    throw Exception(
                        'Failed to add student with status code ${response.statusCode}');
                  }
                });
              },
              child: const Text('Add Student'),
            ),
          ],
        ),
      ),
    );
  }
}
