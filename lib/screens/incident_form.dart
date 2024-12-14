import 'package:flutter/material.dart';

class IncidentFormPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Report Incident"), // Page title
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Back button icon
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous page
          },
        ),
      ),
      body: Center(
        child: Text(
          "Incident Reporting Page", // Placeholder text
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}


