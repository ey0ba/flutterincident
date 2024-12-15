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
        title: Text("Welcome, ${authProvider.username ?? 'User'}"), // Handle null username gracefully
        actions: [

          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              authProvider.logout(); // Reset authentication state
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false, // Remove all previous routes
              );
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
                // Navigate to the incident form and pass the access token
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IncidentFormPage(
                      accessToken: authProvider.accessToken!, // Pass the access token here
                    ),
                  ),
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
