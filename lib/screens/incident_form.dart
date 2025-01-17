import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class IncidentFormPage extends StatefulWidget {
  const IncidentFormPage({super.key});

  @override
  _IncidentFormPageState createState() => _IncidentFormPageState();
}

class _IncidentFormPageState extends State<IncidentFormPage> {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Map<String, List<dynamic>> dropdownData = {};
  String? selectedSex,
      selectedDepartment,
      selectedCause,
      selectedFactor,
      selectedType,
      selectedOutcome,
      selectedAction,
      selectedRole,
      selectedReporterDepartment;
  bool isLoading = true;
  bool isSubmitting = false;

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

  Future<String?> _getAccessToken() async {
    return await secureStorage.read(key: 'access_token');
  }

  Future<void> fetchDropdownData() async {
    final accessToken = await _getAccessToken();

    if (accessToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Access token not found. Please log in again.')),
      );
      Navigator.pop(context);
      return;
    }

    final url = 'https://incident.com.et/api/dropdown-data/';
    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: {'Authorization': 'Bearer $accessToken'},
          )
          .timeout(const Duration(seconds: 10));

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
          SnackBar(content: Text('Failed to load dropdown data: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    }
  }

  Future<void> submitIncident() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => isSubmitting = true);

    final accessToken = await _getAccessToken();

    if (accessToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Access token not found. Please log in again.')),
      );
      setState(() => isSubmitting = false);
      return;
    }

    final url = 'https://incident.com.et/api/submit-incident/';
    final payload = {
      "age": int.tryParse(ageController.text),
      "sex": selectedSex,
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

    int retries = 3;
    while (retries > 0) {
      try {
        final response = await http
            .post(
              Uri.parse(url),
              headers: {
                'Authorization': 'Bearer $accessToken',
                'Content-Type': 'application/json',
              },
              body: json.encode(payload),
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Incident submitted successfully!')),
          );
          Navigator.pop(context);
          break;
        } else {
          retries--;
          if (retries == 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Submission failed: ${response.body}')),
            );
          }
        }
      } catch (e) {
        retries--;
        if (retries == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }

    setState(() => isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Image.asset(
                'assets/images/logo.png', // Path to your logo
                width: 40,
                height: 40,
              ),
            ),
            const Text("Report Incident"),
          ],
        ),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    buildTextInput('Age', ageController, isNumeric: true, required: true),
                    buildDropdown('Sex', dropdownData['sex_choices'], (value) {
                      setState(() => selectedSex = value);
                    }, required: true),
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
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: isSubmitting ? null : submitIncident,
                      child: isSubmitting
                          ? const CircularProgressIndicator()
                          : const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildTextInput(String label, TextEditingController controller,
      {bool isNumeric = false, bool required = false}) {
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

  Widget buildDropdown(String label, List<dynamic>? items, void Function(String?)? onChanged,
      {bool required = false}) {
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
          child: const Text('Select Time'),
        ),
      ],
    );
  }
}
