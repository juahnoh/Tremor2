import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:share/share.dart';
import '../../dotinfo.dart';
import 'package:sensors_plus/sensors_plus.dart' as s;
import 'package:tremor/local_utils/DrawingProvider.dart';
import 'package:provider/provider.dart';



class Pose3Record extends StatefulWidget {
  @override
  State<Pose3Record> createState() => _Pose3RecordState();
}

class _Pose3RecordState extends State<Pose3Record> {

  late double dWidth = MediaQuery.of(context).size.width;
  late double dLength= MediaQuery.of(context).size.longestSide;
  late double posX = dWidth/2;
  late double posY = dLength/2.5;

  bool _isRecording = false;
  int _secondsLeft = 60;
  late Timer _timer;

  bool _accelAvailable = false;
  List<double> _accelData = List.filled(3, 0.0);
  StreamSubscription? _accelSubscription;
  final List<List<dynamic>> _dataStorage = [];

  @override

  Widget build(BuildContext context) {
    var p = Provider.of<DrawingProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('POSE 3', style: Theme.of(context).textTheme.titleMedium),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              iconSize: 20.0,
              icon: Icon(
                _isRecording ? Icons.pause_circle_outlined : Icons.play_circle_outline,
                color: Colors.red,
              ),
              onPressed: () {
                setState(() {
                  if (_isRecording) {
                    _pauseTimer();
                    _stopAccelerometer();
                  } else {
                    _startTimer();
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
            SizedBox(
              width: dWidth,
              height: dLength/1.5,
              child: StreamBuilder<s.GyroscopeEvent>(
                  stream: s.SensorsPlatform.instance.gyroscopeEvents,
                  builder: (context, snapshot)
                  {
                    if (_isRecording==true && snapshot.hasData) {
                      posX = posX + (snapshot.data!.y * 40);
                      posY = posY + (snapshot.data!.x * 40);
                      if(posY.abs()>dLength && posY>0)
                        posY = dLength/2;
                      if(posY.abs()<0)
                        posY =0;
                      if(posX.abs()>dWidth && posX>0)
                        posX = dWidth;
                      if(posX<0)
                        posX = 0;
                      p.drawStart(Offset(posX, posY));
                      p.drawing(Offset(posX, posY));
                      p.drawStart(Offset(posX, posY));
                      p.drawing(Offset(posX, posY));
                    }else{}
                    return Scaffold(
                      body: Stack(
                          children: [
                            Positioned.fill(
                                child: CustomPaint(painter: DrawingPainter(p.lines),)),
                            Transform.translate(
                              offset: Offset(posX, posY),
                              child: const CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.red,
                              ),),
                          ]),
                    );
                  }
              ),
            ),
            SizedBox(height: 5),
            IconButton(
                iconSize:30,
                color: Colors.black,
                onPressed: onResetPressed,
                icon: Icon(Icons.restart_alt)),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _checkAccelerometerStatus();
  }
  // Timer functionalities
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
  void onResetPressed(){
    _timer.cancel();
    setState(() {
      _isRecording = false;
      _secondsLeft = 60;
    });
  }
  // Check if accelerometer is available on the device
  void _checkAccelerometerStatus() async {
    await SensorManager()
        .isSensorAvailable(Sensors.ACCELEROMETER)
        .then((result) {
      setState(() {
        _accelAvailable = result;
      });
    });
  }

  // Start reading accelerometer data and save to storage
  Future<void> _startAccelerometer() async {
    if (_accelSubscription != null) return;
    if (_accelAvailable) {
      final stream = await SensorManager().sensorUpdates(
        sensorId: Sensors.ACCELEROMETER,
        interval: const Duration(milliseconds: 50),
      );
      _accelSubscription = stream.listen((sensorEvent) {
        setState(() {
          _accelData = sensorEvent.data;
          _dataStorage.add([
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
    _saveDataToCSV();
  }

  // Save the data to a CSV file
  Future<void> _saveDataToCSV() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final File file = File('$path/accelerometer_data.csv');

    String csvData = const ListToCsvConverter().convert(_dataStorage);
    await file.writeAsString(csvData);
  }

  // Share the saved CSV data
  void _shareCSV() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final File file = File('$path/accelerometer_data.csv');

    await Share.shareFiles([file.path], subject: 'Accelerometer Data');
  }

  // Stop the accelerometer stream subscription
  void _stopAccelerometer() {
    if (_accelSubscription == null) return;
    _accelSubscription?.cancel();
    _accelSubscription = null;
  }


}
class DrawingPainter extends CustomPainter{
  DrawingPainter(this.lines);
  final List<List<DotInfo>> lines;
  @override
  void paint(Canvas canvas, Size size) {
    for(var oneLine in lines){
      Color color = Colors.black;
      double size = 5;
      var l = <Offset>[];
      var p = Path();
      for(var oneDot in oneLine){
        color = oneDot.color;
        size = oneDot.size;
        l.add(oneDot.offset);
      }
      p.addPolygon(l, false);
      canvas.drawPath(p, Paint()..color = color..strokeWidth=size..strokeCap=StrokeCap.round..style=PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
