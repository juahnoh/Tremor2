import 'package:tremor/patientInfo_screen.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
//import 'dart:html' as html;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String nButton = 'New';
  String dButton = 'View data';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('Home Screen', style: Theme.of(context).textTheme.titleLarge),
        ),
    backgroundColor: Colors.white,
    body:
    Center(
    child:
    SizedBox(
      width: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20,),
          Center(
            child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              side: BorderSide(width: 3, color: Colors.black),
            elevation: 3,
            shadowColor: Colors.black,
            fixedSize: Size.fromHeight(75),
            backgroundColor: Colors.grey,
            ),
        child: Center(
          child: Text( nButton,
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      onPressed: (){
      Navigator.push(
      context,
      MaterialPageRoute(
      builder: (context) =>
      patientInfo()),
      );
      }
      )
      ),
      SizedBox(height: 70,),
      Center(
      child: ElevatedButton(
      style: ElevatedButton.styleFrom(
          side: BorderSide(width: 3, color: Colors.black),
          elevation: 3,
      shadowColor: Colors.black,
      fixedSize: Size.fromHeight(75),
      backgroundColor: Colors.grey
      ),
      child: Center(
      child: Text( dButton,
      style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold
      ),
      ),
      ),
      onPressed: (){
          //html.window.open('https://tremor-32fd3-default-rtdb.firebaseio.com/', 'new tab');
      }
      )
      ),
      ]),
    )));

  }
}
