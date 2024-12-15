import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class IncidentFormPage extends StatefulWidget {
  final String accessToken;

  const IncidentFormPage({Key? key, required this.accessToken}) : super(key: key);

  @override
  _IncidentFormPageState createState() => _IncidentFormPageState();
}

class _IncidentFormPageState extends State<IncidentFormPage> {
  Map<String, List<dynamic>> dropdownData = {};
  String? selectedSex, selectedDepartment, selectedCause, selectedFactor, selectedType, selectedOutcome, selectedAction, selectedRole, selectedReporterDepartment;
  bool isLoading = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController causeOtherController = TextEditingController();
  final TextEditingController factorOtherController = TextEditingController();
  final TextEditingController mitigatingOtherController = TextEditingController();
  final TextEditingController reporterNameController = TextEditingController();
  final TextEditingController otherOpinionsController = TextEditingController();
  DateTime selectedDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchDropdownData();
  }

  Future<void> fetchDropdownData() async {
    final url = 'http://127.0.0.1:8000/api/dropdown-data/';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        final parsedData = json.decode(response.body) as Map<String, dynamic>;
        setState(() {
          dropdownData = parsedData.map((key, value) {
            return MapEntry(key, value as List<dynamic>);
          });
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load dropdown data')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> submitIncident() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final url = 'http://127.0.0.1:8000/api/submit-incident/';
    final payload = {
      "age": int.tryParse(ageController.text),
      "incident_time": selectedDateTime.toIso8601String(),
      "incident_locations": selectedDepartment,
      "suspected_cause": selectedCause,
      "suspected_cause_other": causeOtherController.text,
      "contributing_factor": selectedFactor,
      "contributing_factor_other": factorOtherController.text,
      "mitigating_factor": selectedRole,
      "mitigating_factor_other": mitigatingOtherController.text,
      "incident_type": selectedType,
      "incident_outcome": selectedOutcome,
      "resulting_action": selectedAction,
      "reporter_name": reporterNameController.text,
      "reporter_role": selectedRole,
      "reporter_department": selectedReporterDepartment,
      "other_opinions": otherOpinionsController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
          'Content-Type': 'application/json',
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Incident submitted successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit incident')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Report Incident"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    buildTextInput('Age', ageController, isNumeric: true, required: true),
                    buildDateTimePicker(),
                    buildDropdown('Department', dropdownData['departments'], (value) {
                      setState(() => selectedDepartment = value);
                    }, required: true),
                    buildDropdown('Suspected Cause', dropdownData['suspected_causes'], (value) {
                      setState(() => selectedCause = value);
                    }, required: true),
                    buildTextInput('Other Cause Description', causeOtherController),
                    buildDropdown('Contributing Factor', dropdownData['contributing_factors'], (value) {
                      setState(() => selectedFactor = value);
                    }, required: true),
                    buildTextInput('Other Contributing Factor', factorOtherController),
                    buildDropdown('Mitigating Factor', dropdownData['mitigating_factors'], (value) {
                      setState(() => selectedRole = value);
                    }, required: true),
                    buildTextInput('Other Mitigating Factor', mitigatingOtherController),
                    buildDropdown('Incident Type', dropdownData['incident_types'], (value) {
                      setState(() => selectedType = value);
                    }, required: true),
                    buildDropdown('Incident Outcome', dropdownData['incident_outcomes'], (value) {
                      setState(() => selectedOutcome = value);
                    }, required: true),
                    buildDropdown('Resulting Action', dropdownData['resulting_actions'], (value) {
                      setState(() => selectedAction = value);
                    }, required: true),
                    buildTextInput('Reporter Name', reporterNameController),
                    buildDropdown('Reporter Role', dropdownData['reporter_roles'], (value) {
                      setState(() => selectedRole = value);
                    }, required: true),
                    buildDropdown('Reporter Department', dropdownData['reporter_departments'], (value) {
                      setState(() => selectedReporterDepartment = value);
                    }, required: true),
                    buildTextInput('Other Opinions', otherOpinionsController),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: submitIncident,
                      child: Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildTextInput(String label, TextEditingController controller, {bool isNumeric = false, bool required = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: label),
      validator: required
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter $label';
              }
              return null;
            }
          : null,
    );
  }

  Widget buildDropdown(String label, List<dynamic>? items, void Function(String?)? onChanged, {bool required = false}) {
    return DropdownButtonFormField<String>(
      items: items?.map((item) {
        return DropdownMenuItem<String>(
          value: item['id'].toString(),
          child: Text(item['name']),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label),
      validator: required
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Please select $label';
              }
              return null;
            }
          : null,
    );
  }

  Widget buildDateTimePicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Incident Time: ${selectedDateTime.toLocal()}'),
        TextButton(
          onPressed: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDateTime,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (date != null) {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(selectedDateTime),
              );
              if (time != null) {
                setState(() {
                  selectedDateTime = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    time.hour,
                    time.minute,
                  );
                });
              }
            }
          },
          child: Text('Select Time'),
        ),
      ],
    );
  }
}
