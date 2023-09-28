import 'dart:core';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'completed_task_page.dart';

// StatefulWidget för att hantera uppgifter.
class TaskPage extends StatefulWidget {
  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  // Kontroller för att hantera inmatning av uppgiftstitel och beskrivning.
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Variabler för att hantera valt datum och sprint.
  DateTime? selectedDate;
  String? selectedSprint;
  final List<String> sprints = ["Sprint 1", "Sprint 2", "Sprint 3"];

  // Funktion för att lägga till en ny uppgift i databasen.
  Future<void> _addTask() async {
    if (titleController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('tasks').add({
        'title': titleController.text,
        'description': descriptionController.text,
        'createdAt': DateTime.now().toUtc(),
        'deadline': selectedDate?.toUtc(),
        'sprint': selectedSprint,
        'isCompleted': false,
      });

      // Rensa kontrollerna efter att en uppgift har lagts till.
      titleController.clear();
      descriptionController.clear();

      setState(() {
        selectedDate = null;
        selectedSprint = null;
      });
    }
  }

  // Funktion för att visa en datepicker och låta användaren välja ett datum.
  Future<void> _selectDate(BuildContext context) async {
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
    final orientation = MediaQuery.of(context).orientation;

    return GestureDetector(
      onTap: () {
        // Dölj tangentbordet när användaren trycker någonstans på skärmen.
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text('Uppgifter'),
          actions: <Widget>[
            // Knapp för att navigera till sidan med avklarade uppgifter.
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => CompletedTasksPage()),
                );
              },
              child: Text('Avklarade Uppgifter'),
              style: TextButton.styleFrom(
                primary: Colors.purpleAccent,
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            if (orientation == Orientation.portrait)
              ..._buildPortraitTextFields()
            else
              ..._buildLandscapeTextFields(),

            // Dropdown för att låta användaren välja en sprint.
            DropdownButton<String>(
              value: selectedSprint,
              hint: Text("Välj en sprint"),
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
            // Knapp för att låta användaren välja ett deadline.
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text(selectedDate == null
                  ? 'Välj deadline'
                  : 'Deadline: ${selectedDate!.toLocal().toString().split(' ')[0]}'),
            ),
            SizedBox(height: 16),
            // Knapp för att lägga till en ny uppgift.
            ElevatedButton(
              onPressed: _addTask,
              child: Text('Lägg till Uppgift'),
            ),
            SizedBox(height: 20),
            // Stream för att lyssna på ändringar i uppgifter som inte är avklarade.
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
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tasks[index]['description']),
                          SizedBox(height: 4),
                          Text('Sprint: ${tasks[index]['sprint'] ?? 'Ingen'}'),
                        ],
                      ),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Skapad: ${DateFormat('yyyy-MM-dd, HH:mm').format((tasks[index]['createdAt'] as Timestamp).toDate())}'),
                          SizedBox(height: 4),
                          Text('Deadline: ${DateFormat('yyyy-MM-dd').format((tasks[index]['deadline'] as Timestamp).toDate())}'),
                        ],
                      ),
                      // Checkbox för att markera en uppgift som avklarad.
                      leading: Checkbox(
                        value: tasks[index]['isCompleted'],
                        onChanged: (bool? newValue) async {
                          await FirebaseFirestore.instance
                              .collection('tasks')
                              .doc(tasks[index].id)
                              .update({
                            'isCompleted': newValue,
                          });
                          setState(() {});
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

  // Widgets för att visa textfält i porträttläge.
  List<Widget> _buildPortraitTextFields() {
    return [
      Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: TextField(
          controller: titleController,
          decoration: InputDecoration(
            hintText: 'Uppgiftstitel',
            contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          maxLines: 1,
        ),
      ),
      TextField(
        controller: descriptionController,
        decoration: InputDecoration(
          hintText: 'Uppgiftsbeskrivning',
          contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        maxLines: 3,
      ),
      SizedBox(height: 16),
    ];
  }

  // Widgets för att visa textfält i landskapsläge.
  List<Widget> _buildLandscapeTextFields() {
    return [
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'Uppgiftstitel',
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                hintText: 'Uppgiftsbeskrivning',
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: 16),
    ];
  }
}
