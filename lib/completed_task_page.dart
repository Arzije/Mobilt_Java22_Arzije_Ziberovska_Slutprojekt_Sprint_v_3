import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// En StatelessWidget som representerar sidan för färdiga uppgifter.
class CompletedTasksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Avklarade Uppgifter')),
      body: StreamBuilder<QuerySnapshot>(
        // Stream från Firestore för att lyssna på ändringar i uppgifter som har markerats som avklarade.
        stream: FirebaseFirestore.instance
            .collection('tasks')
            .where('isCompleted', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          // Om data inte har hämtats ännu, visa en laddningsindikator.
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final completedTasks = snapshot.data!.docs;

          // Om det inte finns några avklarade uppgifter, visa ett meddelande om det.
          if (completedTasks.isEmpty) {
            return Center(child: Text('Inga avklarade uppgifter än.'));
          }

          // Skapa en lista av avklarade uppgifter.
          return ListView.builder(
            itemCount: completedTasks.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(completedTasks[index]['title']),
                subtitle: Text(completedTasks[index]['description']),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Skapad: ${DateFormat('HH:mm yyyy-MM-dd').format(completedTasks[index]['createdAt'].toDate())}'
                    ),
                    SizedBox(height: 4),
                    Text(
                        completedTasks[index]['deadline'] is Timestamp
                            ? 'Deadline: ${(completedTasks[index]['deadline'] as Timestamp).toDate().toString().split(' ')[0]}'
                            : 'Ingen deadline'
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
