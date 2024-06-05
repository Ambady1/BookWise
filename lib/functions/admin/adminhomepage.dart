
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {

   String? _fileContent;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'json'],
    );

    if (result != null) {

      // ...

      File file = File(result.files.single.path!);
      if (file.path.endsWith('.csv')) {
        String csvData = await file.readAsString();
        setState(() {
          _fileContent = csvData;
        });
      } else if (file.path.endsWith('.json')) {
        String jsonData = await file.readAsString();
        setState(() {
          _fileContent = jsonData;
        });
      }
    } else {
      // User canceled the file picker
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

   body:  Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _pickFile,
                  child: Text('Pick File'),
                ),
                SizedBox(height: 20),
                _fileContent != null
                    ? Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            _fileContent!,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      )
                    : Container(),
          ],
        ),
      ),
    );
  }
}