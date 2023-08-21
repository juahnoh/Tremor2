import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:tremor/PoseChoice.dart';


class patientInfo extends StatefulWidget {
  const patientInfo({super.key});
  @override
  State<patientInfo> createState() => _patientInfoState();
}


class _patientInfoState extends State<patientInfo> {
  TextEditingController patientNumber = new TextEditingController();
  String age ='';
  late  DateTime Date;
  TextEditingController dateInput = TextEditingController();
  String Sex='NA';
  bool history=false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('New Patient', style: Theme.of(context).textTheme.titleMedium),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 100),
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 20,),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Patient number:',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600 ),),
                  Container(
                      width: 200,
                      child: TextField(
                        controller: patientNumber,
                        decoration: InputDecoration(
                            labelText: 'NUMBER'
                        ),
                      )
                  )
                ],
              ),
              SizedBox(height: 20,),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Age:',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600 ),),
                  Container(
                      width: 200,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        onChanged: (old){
                          setState(() {
                            age=old;
                          }
                          );
                        },
                        decoration: InputDecoration(
                            labelText: 'AGE'
                        ),
                      )
                  )
                ],
              ),
              SizedBox(height: 20,),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Date:',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600 ),),
                  Container(
                    width: 200,
                    child: TextField(
                      controller: dateInput,
                      decoration: InputDecoration(
                          icon: Icon(Icons.calendar_month_outlined),
                          labelText: 'Enter Date'
                      ),
                      readOnly: true,
                      onTap: () async{
                        DateTime? pickedDate=await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1950),
                            lastDate: DateTime.now());
                        if (pickedDate != null){
                          print(pickedDate);
                          String formedDate= pickedDate.toString().substring(0,10);
                          print(formedDate);
                          setState(() {
                            dateInput.text= formedDate;
                          });
                        }else {}
                      },
                    ),)
                ],
              ),
              SizedBox(height: 20,),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Sex:',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600 ),),
                  Container(
                    width: 200,
                    child: DropdownButton<String>(
                        value: Sex,
                        items: const[
                          DropdownMenuItem(
                            child: Text('NA'), value: ('NA'),),
                          DropdownMenuItem(
                            child: Text('Female'), value: ('F'),),
                          DropdownMenuItem(
                            child: Text('Male'), value: ('M'),),
                        ],
                        onChanged: (String? value){
                          setState(() {
                            Sex = value!;
                          });
                        }
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20,),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Diagnosed history:',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600 ),),
                  Container(
                    width: 200,
                    child: DropdownButton<bool>(
                        value: history,
                        items: const[
                          DropdownMenuItem(
                            child: Text('No'), value: (false),),
                          DropdownMenuItem(
                            child: Text('Yes'), value: (true),),
                        ],
                        onChanged: (bool? value){
                          setState(() {
                            history = value!;
                          });
                        }
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20,),
              IconButton(onPressed: (){
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) =>
                          PoseChoice(patientNum: patientNumber.text)),
                );
              }, icon: Icon(Icons.check_box_outlined))
            ],
          ),
        ),
      ),
    );
  }
}
