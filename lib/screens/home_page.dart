import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'incident_form.dart'; // Import the new form page



class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, ${authProvider.username}"), // Display logged-in username
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              Navigator.pushReplacementNamed(context, '/login'); // Navigate back to login
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => IncidentFormPage()),
                );
              },
              child: Text("Report Incident"),
            ),

            SizedBox(height: 16), // Add spacing between buttons
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Dummy Button clicked!")),
                );
              },
              child: Text("Dummy Button"),
            ),
          ],
        ),
      ),
    );
  }
}
