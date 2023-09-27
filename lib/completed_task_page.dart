import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CompletedTasksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Completed Tasks')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tasks')
            .where('isCompleted', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final completedTasks = snapshot.data!.docs;

          if (completedTasks.isEmpty) {
            return Center(child: Text('No completed tasks yet.'));
          }

          return ListView.builder(
            itemCount: completedTasks.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(completedTasks[index]['title']),
                subtitle: Text(completedTasks[index]['description']),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Created: ${DateFormat('HH:mm yyyy-MM-dd').format(completedTasks[index]['createdAt'].toDate())}'
                    ),
                    SizedBox(height: 4),
                    Text(
                        completedTasks[index]['deadline'] is Timestamp
                            ? 'Deadline: ${(completedTasks[index]['deadline'] as Timestamp).toDate().toString().split(' ')[0]}'
                            : 'No deadline'
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}


