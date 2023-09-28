import 'dart:core';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'completed_task_page.dart';

class TaskPage extends StatefulWidget {
  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  // final TextEditingController sprintController = TextEditingController();

  DateTime? selectedDate;

  String? selectedSprint;
  final List<String> sprints = ["Sprint 1", "Sprint 2", "Sprint 3"]; // You can extend this list


  Future<void> _addTask() async {
    if (titleController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('tasks').add({
        'title': titleController.text,
        'description': descriptionController.text,
        'createdAt': DateTime.now().toUtc(), // Formaterar till HH:mm-format
        'deadline': selectedDate?.toUtc(),
        'sprint': selectedSprint,
        'isCompleted': false,
      });

      // Rensa textfälten efter att ha lagt till uppgiften
      titleController.clear();
      descriptionController.clear();
      // sprintController.clear();

      setState(() {
        selectedDate = null;
        selectedSprint = null;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    // Funktion för att visa dataväljaren
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context)
            .unfocus(); // Detta kommer att gömma tangentbordet
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text('Tasks'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => CompletedTasksPage()),
                );
              },
              child: Text('Completed Tasks'),
              style: TextButton.styleFrom(
                primary: Colors.purpleAccent, // Detta sätter textfärgen till vit
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'Task Title',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                hintText: 'Task Description',
              ),
            ),
            SizedBox(height: 16),
            DropdownButton<String>(  // ADDED
              value: selectedSprint,
              hint: Text("Select a sprint"),
              onChanged: (String? newValue) {
                setState(() {
                  selectedSprint = newValue;
                });
              },
              items: sprints.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _selectDate(context), // Visa dataväljaren
              child: Text(selectedDate == null
                  ? 'Select deadline'
                  : 'Deadline: ${selectedDate!.toLocal().toString().split(' ')[0]}'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addTask,
              child: Text('Add Task'),
            ),
            SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tasks')
                  .where('isCompleted', isEqualTo: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final tasks = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      subtitle: Column(  // ADDED: Wrap the subtitle in a Column
                        crossAxisAlignment: CrossAxisAlignment.start, // ADDED
                        children: [  // ADDED
                          Text(tasks[index]['description']),
                          SizedBox(height: 4),  // ADDED
                          Text('Sprint: ${tasks[index]['sprint'] ?? 'None'}'),  // ADDED: Display the sprint
                        ],
                      ),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Created: ${DateFormat('yyyy-MM-dd, HH:mm').format((tasks[index]['createdAt'] as Timestamp).toDate())}'),

                          SizedBox(height: 4),

                          Text('Deadline: ${DateFormat('yyyy-MM-dd').format((tasks[index]['deadline'] as Timestamp).toDate())}'),
                        ],
                      ),
                      leading: Checkbox(
                        value: tasks[index]['isCompleted'],
                        onChanged: (bool? newValue) async {
                          await FirebaseFirestore.instance
                              .collection('tasks')
                              .doc(tasks[index].id)
                              .update({
                            'isCompleted': newValue,
                          });
                          setState(() {}); // Uppdatera UI
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
