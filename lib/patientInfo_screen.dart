import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:tremor/PoseChoice.dart';
import 'package:firebase_database/firebase_database.dart';

class patientInfo extends StatefulWidget {
  const patientInfo({super.key});
  @override
  State<patientInfo> createState() => _patientInfoState();
}

class _patientInfoState extends State<patientInfo> {
  TextEditingController patientNumber = TextEditingController();
  String age = '';
  late DateTime Date ;
  TextEditingController dateInput = TextEditingController();
  String Sex = 'NA';
  bool history = false;
  late DatabaseReference dataRef;
  @override
  void initState(){
    super.initState();
    dataRef = FirebaseDatabase.instance.ref('patient information list');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title:
            Text('New Patient', style: Theme.of(context).textTheme.titleMedium),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 100),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Patient number:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      width: 200,
                      child: TextField(
                        controller: patientNumber,
                        decoration: const InputDecoration(labelText: 'NUMBER'),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Age:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      width: 200,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        onChanged: (old) {
                          setState(() {
                            age = old;
                          });
                        },
                        decoration: const InputDecoration(labelText: 'AGE'),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Date:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      width: 200,
                      child: TextField(
                        controller: dateInput,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.calendar_month_outlined),
                          labelText: 'Enter Date',
                        ),
                        readOnly: true,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1950),
                              lastDate: DateTime.now());
                          if (pickedDate != null) {
                            String formedDate =
                                pickedDate.toString().substring(0, 10);
                            setState(() {
                              dateInput.text = formedDate;
                              Date = pickedDate;
                            });
                          }
                        },
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sex:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      width: 200,
                      child: DropdownButton<String>(
                        value: Sex,
                        items: const [
                          DropdownMenuItem(
                            value: ('NA'),
                            child: Text('NA'),
                          ),
                          DropdownMenuItem(
                            value: ('F'),
                            child: Text('Female'),
                          ),
                          DropdownMenuItem(
                            value: ('M'),
                            child: Text('Male'),
                          ),
                        ],
                        onChanged: (String? value) {
                          setState(() {
                            Sex = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Diagnosed history:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      width: 200,
                      child: DropdownButton<bool>(
                        value: history,
                        items: const [
                          DropdownMenuItem(
                            value: (false),
                            child: Text('No'),
                          ),
                          DropdownMenuItem(
                            value: (true),
                            child: Text('Yes'),
                          ),
                        ],
                        onChanged: (bool? value) {
                          setState(() {
                            history = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                IconButton(
                  onPressed: () {
                    sendData();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) =>
                              PoseChoice(patientNum: patientNumber.text)),

                    );
                  },
                  icon: const Icon(Icons.check_box_outlined),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void sendData() async{
    return await dataRef.child('patient ${patientNumber.text.toString()}').push().set({
      'Patient Num' : '${patientNumber.text}',
      'Age' : '$age',
      'Date' : '${Date.toString().substring(0, 10)}',
      'Sex' : '$Sex',
      'Diagnosed history' : '$history' ,
    });
  }
}
