import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Pose2Record extends StatefulWidget {
  String patientNum;
  Pose2Record({super.key,required this.patientNum});

  @override
  _Pose2RecordState createState() => _Pose2RecordState();
}

class _Pose2RecordState extends State<Pose2Record> {
  bool _isRecording = false;
  int _secondsLeft = 60;
  late Timer _timer;

  bool _gyroAvailable = false;
  bool _accelAvailable = false;
  List<double> _gyroData = List.filled(3, 0.0);
  List<double> _accelData = List.filled(3, 0.0);
  StreamSubscription? _gyroSubscription;
  StreamSubscription? _accelSubscription;
  final List<List<dynamic>> _dataStorageG = [];
  final List<List<dynamic>> _dataStorageA = [];

  @override
  void initState() {
    super.initState();
    _checkGyroroscopeStatus();
    _checkAccelerometerStatus();
  }

  // Timer functionalities
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 0) {
        _isRecording=false;
        timer.cancel();
        _stopAccelerometer();
        _stopGyroscope();
      }
      if (_isRecording) {
        setState(() {
          _secondsLeft--;
        });
      }
    });
  }

  void _pauseTimer() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    setState(() {
      _isRecording = false;
    });
  }

  void _checkGyroroscopeStatus() async {
    await SensorManager()
        .isSensorAvailable(Sensors.GYROSCOPE)
        .then((result) {
      setState(() {
        _gyroAvailable = result;
      });
    });
  }
  void _checkAccelerometerStatus() async {
    await SensorManager()
        .isSensorAvailable(Sensors.ACCELEROMETER)
        .then((result) {
      setState(() {
        _accelAvailable = result;
      });
    });
  }

  Future<void> _startGyroscope() async {
    if (_gyroSubscription != null) return;
    if (_gyroAvailable) {
      final stream = await SensorManager().sensorUpdates(
        sensorId: Sensors.GYROSCOPE,
        interval: const Duration(milliseconds: 5),
      );
      _gyroSubscription = stream.listen((sensorEvent) {
        setState(() {
          _gyroData = sensorEvent.data;
          _dataStorageG.add([
            DateTime.now().millisecondsSinceEpoch,
            _gyroData[0],
            _gyroData[1],
            _gyroData[2]
          ]);
        });
      });
    }
  }
  Future<void> _startAccelerometer() async {
    if (_accelSubscription != null) return;
    if (_accelAvailable) {
      final stream = await SensorManager().sensorUpdates(
        sensorId: Sensors.ACCELEROMETER,
        interval: const Duration(milliseconds: 5),
      );
      _accelSubscription = stream.listen((sensorEvent) {
        setState(() {
          _accelData = sensorEvent.data;
          _dataStorageA.add([
            DateTime.now().millisecondsSinceEpoch,
            _accelData[0],
            _accelData[1],
            _accelData[2]
          ]);
        });
      });
    }
  }

  // Reset timer and save data when recording finishes
  void _resetTimer() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    setState(() {
      _isRecording = false;
      _secondsLeft = 60;
    });
    _printTable();
  }


  // Print the table (data) in the console
  void _printTable() {
    for (var row in _dataStorageA) {
      print(row);
    }
  }


  void _stopGyroscope() {
    if (_gyroSubscription == null) return;
    _gyroSubscription?.cancel();
    _gyroSubscription = null;
  }
  void _stopAccelerometer() {
    if (_accelSubscription == null) return;
    _accelSubscription?.cancel();
    _accelSubscription = null;
  }
  void onResetPressed() {
    _timer.cancel();
    setState(() {
      _isRecording = false;
      _secondsLeft = 60;
    });
    Navigator.of(context).popUntil((route) => route.isCurrent);
  }

  // UI Building
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: (_isRecording)? Colors.green: Colors.orange,
        title:
        Text('POSE 2', style: Theme.of(context).textTheme.headlineMedium),
      ),
      body: Center(
        child: Stack(
            children:<Widget>[ Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    iconSize: 50.0,
                    icon: Icon(
                      _isRecording
                          ? Icons.pause_circle_outlined
                          : Icons.play_circle_outline,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      setState(() {
                        if (_isRecording) {
                          _pauseTimer();
                          _stopGyroscope();
                          _stopAccelerometer();
                        } else {
                          _startTimer();
                          _startGyroscope();
                          _startAccelerometer();
                          _isRecording = true;
                        }
                      });
                    },
                  ),
                  Text(
                    '00:${_secondsLeft.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 5),
                  (_secondsLeft==0)? IconButton(
                      iconSize: 50,
                      color: Colors.black,
                      onPressed: (){
                        sendfileA();
                        sendfileG();
                      } ,
                      icon: Icon( Icons.upload_file_outlined)):SizedBox(height: 50,),
                  IconButton(
                      iconSize: 30,
                      color: Colors.black,
                      onPressed: onResetPressed,
                      icon: const Icon(Icons.restart_alt)),
                ],
              ),
            ), (loading)? Center(child: CircularProgressIndicator(),):Center()]
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    _stopAccelerometer();
    _stopGyroscope();
    super.dispose();
  }
  bool loading = false;

  FirebaseStorage storage = FirebaseStorage.instance;
  void sendfileA () async{
    final directoryA = await getApplicationDocumentsDirectory();
    final pathA = directoryA.path;
    final File fileA = File('$pathA/accelerometer_data.csv');


    String csvDataA = const ListToCsvConverter().convert(_dataStorageA);
    await fileA.writeAsString(csvDataA);

    if(fileA==null) return;

    this.setState(() {
      loading = true;
    });
    Reference storageReferenceA = storage.ref().child("#${widget.patientNum}_accPose2_${DateTime.now().minute}.csv");
    UploadTask uploadTaskA = storageReferenceA.putFile(fileA);
    await uploadTaskA.whenComplete(() =>
        this.setState(() {
          loading = false;
        }
        )
    );
  }
  void sendfileG () async{
    final directoryG = await getApplicationDocumentsDirectory();
    final pathG = directoryG.path;
    final File fileG = File('$pathG/gyroscope_data.csv');
    String csvDataG = const ListToCsvConverter().convert(_dataStorageG);
    await fileG.writeAsString(csvDataG);

    if(fileG==null) return;

    this.setState(() {
      loading = true;
    });
    Reference storageReferenceG = storage.ref().child("#${widget.patientNum}_gyroPose2_${DateTime.now().minute}.csv");
    UploadTask uploadTaskG = storageReferenceG.putFile(fileG);
    await uploadTaskG.whenComplete(() =>
        this.setState(() {
          loading = false;
        }
        )
    );
  }
}
