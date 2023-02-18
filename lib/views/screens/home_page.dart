import 'dart:typed_data';

import 'package:adv_6pm_sqlite_app/helpers/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormState> insertFormKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController courseController = TextEditingController();

  String? name;
  int? age;
  String? course;
  Uint8List? image;

  late Future<List<Map<String, dynamic>>> getData;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    getData = DBHelper.dbHelper.fetchAllRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SQLite App"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () async {
              await DBHelper.dbHelper.deleteAllRecords();

              setState(() {
                getData = DBHelper.dbHelper.fetchAllRecords();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                decoration: InputDecoration(hintText: "Search by name"),
                onChanged: (val) {
                  setState(() {
                    getData = DBHelper.dbHelper.fetchSearchedRecords(name: val);
                  });
                },
              ),
            ),
          ),
          Expanded(
            flex: 10,
            child: FutureBuilder(
              future: getData,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text("ERROR: ${snapshot.error}"),
                  );
                } else if (snapshot.hasData) {
                  List<Map<String, dynamic>>? data = snapshot.data;

                  return (data != null)
                      ? ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, i) {
                            return Card(
                              elevation: 3,
                              child: ListTile(
                                isThreeLine: true,
                                leading: CircleAvatar(
                                  radius: 20,
                                  backgroundImage: (data[i]['image'] != null)
                                      ? MemoryImage(
                                          data[i]['image'] as Uint8List)
                                      : null,
                                ),
                                title: Text("${data[i]['name']}"),
                                subtitle: Text(
                                    "${data[i]['course']}\nAge: ${data[i]['age']}"),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () async {
                                        int res = await DBHelper.dbHelper
                                            .updateRecord(
                                          name: "Piyush",
                                          age: 24,
                                          course: "Flutter",
                                          image: null,
                                          id: data[i]['id'],
                                        );

                                        if (res == 1) {
                                          setState(() {
                                            getData = DBHelper.dbHelper
                                                .fetchAllRecords();
                                          });

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "Record updated successfully..."),
                                              backgroundColor: Colors.green,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "Record updation failed..."),
                                              backgroundColor: Colors.red,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () async {
                                        int res = await DBHelper.dbHelper
                                            .deleteRecord(id: data[i]['id']);

                                        if (res == 1) {
                                          setState(() {
                                            getData = DBHelper.dbHelper
                                                .fetchAllRecords();
                                          });

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "Record deleted successfully..."),
                                              backgroundColor: Colors.green,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "Record deletion failed..."),
                                              backgroundColor: Colors.red,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Text("No data..."),
                        );
                }

                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: validateAndInsert,
      ),
    );
  }

  void validateAndInsert() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(
            child: Text("Insert Record"),
          ),
          content: Form(
            key: insertFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    XFile? xfile = await picker.pickImage(
                        source: ImageSource.camera, imageQuality: 70);

                    image = await xfile!.readAsBytes();
                  },
                  child: const CircleAvatar(
                    child: Text("Pick Image"),
                    radius: 60,
                  ),
                ),
                TextFormField(
                  controller: nameController,
                  validator: (val) {
                    return (val!.isEmpty) ? "Enter name first..." : null;
                  },
                  onSaved: (val) {
                    name = val;
                  },
                  decoration: const InputDecoration(
                      hintText: "Enter name here...",
                      labelText: "Name",
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    return (val!.isEmpty) ? "Enter age first..." : null;
                  },
                  onSaved: (val) {
                    age = int.parse(val!);
                  },
                  decoration: const InputDecoration(
                      hintText: "Enter age here...",
                      labelText: "Age",
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: courseController,
                  validator: (val) {
                    return (val!.isEmpty) ? "Enter course first..." : null;
                  },
                  onSaved: (val) {
                    course = val;
                  },
                  decoration: const InputDecoration(
                      hintText: "Enter course here...",
                      labelText: "Course",
                      border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (insertFormKey.currentState!.validate()) {
                  insertFormKey.currentState!.save();

                  int id = await DBHelper.dbHelper.insertRecord(
                      name: name!, age: age!, course: course!, image: image);

                  if (id > 0) {
                    setState(() {
                      getData = DBHelper.dbHelper.fetchAllRecords();
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text("Id: $id, Record inserted successfully..."),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Record insertion failed..."),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }

                  setState(() {
                    nameController.clear();
                    ageController.clear();
                    courseController.clear();

                    name = null;
                    age = null;
                    course = null;
                    image = null;
                  });

                  Navigator.of(context).pop();
                }
              },
              child: const Text("Insert"),
            ),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  nameController.clear();
                  ageController.clear();
                  courseController.clear();

                  name = null;
                  age = null;
                  course = null;
                  image = null;
                });
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }
}
