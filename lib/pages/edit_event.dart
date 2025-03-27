import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'consts.dart';
import 'edit_event_detail.dart'; 

class EditEventScreen extends StatefulWidget {
  final String userId;

  const EditEventScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor, 
      appBar: AppBar(
        title: Text('Edit Events'.tr()),
        backgroundColor: buttonColor, 
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: firestore.collection('events').where('createdBy', isEqualTo: widget.userId).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            List<DocumentSnapshot> userEvents = snapshot.data!.docs;

            if (userEvents.isEmpty) {
              return Center(
                child: Text('No Events Found'.tr(), style: const TextStyle(color: Colors.white70, fontSize: 18)),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Tap to edit, long press to delete'.tr(),
                    style: const TextStyle(color: Colors.white70, fontSize: 14, fontStyle: FontStyle.italic),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Two columns
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.2, // Adjusted height-to-width ratio
                    ),
                    itemCount: userEvents.length,
                    itemBuilder: (context, index) {
                      var event = userEvents[index];
                      return GestureDetector(
                        onTap: () => _editEvent(event), // Edit event
                        onLongPress: () => _confirmDelete(event), // Delete event
                        child: Card(
                          color: Colors.grey[900], // Dark theme
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                child: event['posterUrl'] != null && event['posterUrl']!.isNotEmpty
                                    ? Image.network(
                                        event['posterUrl'],
                                        height: 100, // Reduced image height
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        height: 80, // Reduced placeholder height
                                        color: Colors.grey[700],
                                        child: const Icon(Icons.image, color: Colors.white70, size: 40),
                                      ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0), // Reduced padding
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event['eventName'],
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      "${event['date']} • ${event['startTime']}",
                                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _editEvent(DocumentSnapshot event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEventDetailScreen(eventData: event), 
      ),
    );
  }

  void _confirmDelete(DocumentSnapshot event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: Text('Delete Event'.tr(), style: const TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete this event?'.tr(), style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'.tr(), style: const TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              await firestore.collection('events').doc(event.id).delete();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Event Deleted Successfully!'.tr()), backgroundColor: Colors.red),
              );
            },
            child: Text('Delete'.tr(), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
