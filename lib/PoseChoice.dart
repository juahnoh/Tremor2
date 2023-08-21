import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tremor/Pose1/Pose1Record_screen.dart';
import 'package:tremor/Pose2/Pose2Record_screen.dart';
import 'package:tremor/Pose3/Pose3Record_screen.dart';
import 'package:tremor/Progressing_screen.dart';
import 'dart:ui';
import 'package:tremor/patientInfo_screen.dart';

class PoseChoice extends StatefulWidget {
  String patientNum;
  PoseChoice({required this.patientNum});

  @override
  State<PoseChoice> createState() => _PoseChoiceState();
}

class _PoseChoiceState extends State<PoseChoice> {
  String first = 'POSE 1';
  String second = 'POSE 2';
  String third = 'POSE 3';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('Patient # ${widget.patientNum}',style: Theme.of(context).textTheme.titleMedium),
      ),
      body: Padding(
        padding: const EdgeInsets.all(60),
        child: Center(
          child: SizedBox(
            width: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Pose1Record()),
                  );
                }, child:
                Center(
                  child: Text( first,
                    style: TextStyle(color: Colors.black, fontSize: 20,fontWeight: FontWeight.bold),
                  ),
                ),
                  style: ElevatedButton.styleFrom(
                      side: BorderSide(width: 3, color: Colors.black),
                      elevation: 3,
                      shadowColor: Colors.black,
                      fixedSize: Size.fromHeight(65),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)
                      ),
                      backgroundColor: Colors.grey
                  ),
                ),
                SizedBox(height: 30,),
                ElevatedButton(onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Pose2Record()),
                  );
                }, child:
                    Center(
                      child: Text( second,
                        style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  style: ElevatedButton.styleFrom(
                      side: BorderSide(width: 3, color: Colors.black),
                      elevation: 3,
                      shadowColor: Colors.black,
                      fixedSize: Size.fromHeight(65),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                      ),
                      backgroundColor: Colors.grey
                  ),
                ),
                SizedBox(height: 30,),
                ElevatedButton(onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Pose3Record()),
                  );
                }, child:
                  Center(
                  child: Text( third,
                    style: TextStyle(color: Colors.black, fontSize: 20,fontWeight: FontWeight.bold),
                  ),
                ),
                  style: ElevatedButton.styleFrom(
                      side: BorderSide(width: 3, color: Colors.black),
                      elevation: 3,
                      shadowColor: Colors.black,
                      fixedSize: Size.fromHeight(65),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                      ),
                      backgroundColor: Colors.grey
                  ),
                ),
                SizedBox(height: 40,),
                IconButton(onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Progressing()),
                  );
                }, icon: Icon(Icons.upload_file_outlined, size: 40,))

              ],
            ),
          ),
        ),
      ),
    );
  }
}
