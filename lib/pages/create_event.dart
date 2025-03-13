import 'package:assignment1/pages/consts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  Uint8List? uploadedFileBytes;
  String? uploadedFileName;

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025, 12, 31),
    );
    if (pickedDate != null) {
      setState(() {
        dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        timeController.text = pickedTime.format(context);
      });
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        uploadedFileBytes = result.files.single.bytes;
        uploadedFileName = result.files.single.name;
      });
    }
  }

  Future<String?> _uploadToFirebaseStorage(Uint8List fileBytes, String fileName) async {
    try {
      String filePath = 'posters/$fileName';
      Reference ref = storage.ref().child(filePath);
      UploadTask uploadTask = ref.putData(fileBytes);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading to Firebase Storage: $e");
      return null;
    }
  }

  void _createEvent() async {
    if (eventNameController.text.isEmpty ||
        dateController.text.isEmpty ||
        timeController.text.isEmpty ||
        descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    String? posterUrl;
    if (uploadedFileBytes != null && uploadedFileName != null) {
      posterUrl = await _uploadToFirebaseStorage(uploadedFileBytes!, uploadedFileName!);
    }

    String eventNameKey = eventNameController.text.trim().replaceAll(' ', '_');

    await firestore.collection('events').doc(eventNameKey).set({
      'eventName': eventNameController.text,
      'date': dateController.text,
      'time': timeController.text,
      'description': descriptionController.text,
      'posterUrl': posterUrl ?? '',
      'createdAt': DateTime.now().toIso8601String(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Event Created Successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // Reset fields after event creation
    eventNameController.clear();
    dateController.clear();
    timeController.clear();
    descriptionController.clear();
    setState(() {
      uploadedFileBytes = null;
      uploadedFileName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        title: const Text('Create Event'),
        backgroundColor: buttonColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: grey),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Event Name', eventNameController),
            const SizedBox(height: 12),
            _buildDateTimeField('Select Date', dateController, _selectDate),
            const SizedBox(height: 12),
            _buildDateTimeField('Select Time', timeController, _selectTime),
            const SizedBox(height: 12),
            _buildTextField('Description', descriptionController, maxLines: 3),
            const SizedBox(height: 12),
            _buildFilePicker(),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _createEvent,
                icon: const Icon(Icons.event_available, color: grey),
                label: const Text("Create Event"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: grey,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[800],
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildDateTimeField(String label, TextEditingController controller, Function(BuildContext) onTap) {
    return InkWell(
      onTap: () => onTap(context),
      child: IgnorePointer(
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white70),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[800],
            suffixIcon: const Icon(Icons.calendar_today, color: buttonColor),
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFilePicker() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _pickFile,
          icon: const Icon(Icons.upload_file, color: grey),
          label: const Text("Upload Poster"),
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: grey,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        if (uploadedFileBytes != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Image.memory(uploadedFileBytes!, height: 100), // Show image preview
          ),
      ],
    );
  }
}
