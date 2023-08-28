import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tremor/Pose1/Pose1Record_screen.dart';
import 'package:tremor/Pose2/Pose2Record_screen.dart';
import 'package:tremor/Pose3/Pose3Record_screen.dart';
import 'package:tremor/Pose4/Pose4Record_screen.dart';
import 'package:tremor/home.dart';
import 'dart:ui';
import 'package:tremor/patientInfo_screen.dart';
import 'package:tremor/local_utils/DrawingProvider.dart';
import 'package:provider/provider.dart';

class PoseChoice extends StatefulWidget {
  String patientNum;
  PoseChoice({super.key, required this.patientNum});

  @override
  State<PoseChoice> createState() => _PoseChoiceState();
}

class _PoseChoiceState extends State<PoseChoice> {
  String first = 'POSE 1';
  String second = 'POSE 2';
  String third = 'POSE 3';
  String fourth = 'POSE 4';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('Patient # ${widget.patientNum}',
            style: Theme.of(context).textTheme.titleMedium),
      ),
      body: Padding(
        padding: const EdgeInsets.all(60),
        child: Center(
          child: SizedBox(
            width: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider(
                          create: (context) => DrawingProvider(),
                          child: Pose1Record(patientNum: widget.patientNum),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      side: const BorderSide(width: 3, color: Colors.black),
                      elevation: 3,
                      shadowColor: Colors.black,
                      fixedSize: const Size.fromHeight(65),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      backgroundColor: Colors.grey),
                  child: Center(
                    child: Text(
                      first,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider(
                          create: (context) => DrawingProvider(),
                          child: Pose2Record(patientNum: widget.patientNum),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      side: const BorderSide(width: 3, color: Colors.black),
                      elevation: 3,
                      shadowColor: Colors.black,
                      fixedSize: const Size.fromHeight(65),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      backgroundColor: Colors.grey),
                  child: Center(
                    child: Text(
                      second,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider(
                          create: (context) => DrawingProvider(),
                          child: Pose3Record(patientNum: widget.patientNum),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      side: const BorderSide(width: 3, color: Colors.black),
                      elevation: 3,
                      shadowColor: Colors.black,
                      fixedSize: const Size.fromHeight(65),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      backgroundColor: Colors.grey),
                  child: Center(
                    child: Text(
                      third,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider(
                          create: (context) => DrawingProvider(),
                          child: Pose4Record(patientNum: widget.patientNum),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      side: const BorderSide(width: 3, color: Colors.black),
                      elevation: 3,
                      shadowColor: Colors.black,
                      fixedSize: const Size.fromHeight(65),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      backgroundColor: Colors.grey),
                  child: Center(
                    child: Text(
                      fourth,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Home()),
                      );
                    },
                    icon: const Icon(
                      Icons.upload_file_outlined,
                      size: 40,
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}