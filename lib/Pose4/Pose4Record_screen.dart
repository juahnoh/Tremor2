import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:share/share.dart';
import 'package:sensors_plus/sensors_plus.dart' as s;
import 'package:tremor/local_utils/DrawingProvider.dart';
import 'package:provider/provider.dart';
import '../../dotinfo.dart';
import 'package:screenshot/screenshot.dart';
import 'package:percent_indicator/percent_indicator.dart';


class Pose4Record extends StatefulWidget {
  String patientNum;
  Pose4Record({super.key,required this.patientNum});

  @override
  State<Pose4Record> createState() => _Pose4RecordState();
}

class _Pose4RecordState extends State<Pose4Record> {
  late double dWidth;
  late double dLength;
  late double posX;
  late double posY;
  final controller = ScreenshotController();

  bool _isRecording = false;
  int _secondsLeft = 20;
  late Timer _timer;
  bool _gyroAvailable = false;
  bool _accelAvailable = false;
  List<double> _gyroData = List.filled(3, 0.0);
  List<double> _accelData = List.filled(3, 0.0);
  StreamSubscription? _gyroSubscription;
  StreamSubscription? _accelSubscription;
  final List<List<dynamic>> _dataStorageG = [];
  final List<List<dynamic>> _dataStorageA = [];
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
    Reference storageReferenceA = storage.ref().child("#${widget.patientNum}_accPose4_${DateTime.now().minute}.csv");
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
    Reference storageReferenceG = storage.ref().child("#${widget.patientNum}_gyroPose4_${DateTime.now().minute}.csv");
    UploadTask uploadTaskG = storageReferenceG.putFile(fileG);
    await uploadTaskG.whenComplete(() =>
        this.setState(() {
          loading = false;
        }
        )
    );
  }
  void sendImage () async{
    final image = await controller.capture();
    if(image==null) return;
    Uint8List cImage = image.buffer.asUint8List();
    this.setState(() {
      loading = true;
    });
    Reference storageReference = storage.ref().child("#${widget.patientNum}_Pose4_${DateTime.now().minute}.png");
    UploadTask uploadTask = storageReference.putData(cImage);

    await uploadTask.whenComplete(() =>
        this.setState(() {
          loading = false;
        }
        )
    );
  }

  @override
  void initState() {
    super.initState();
    _checkGyroroscopeStatus();
    _checkAccelerometerStatus();
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


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dWidth = MediaQuery.of(context).size.width;
    dLength = MediaQuery.of(context).size.height;
    posX = dWidth/2 ;
    posY = dLength/9;
  }

  @override
  Widget build(BuildContext context) {
    var p = DrawingProvider();
    p = context.read<DrawingProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title:
        Text('POSE 4', style: Theme.of(context).textTheme.headlineMedium),
      ),
      body: Center(
        child: Stack(
            children:<Widget>[ Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  iconSize: 20.0,
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
                SizedBox(
                  width: dWidth,
                  height: dWidth,
                  child: Center(
                    child:  StreamBuilder<s.GyroscopeEvent>(
                        stream: s.SensorsPlatform.instance.gyroscopeEvents,
                        builder: (context, snapshot) {
                          if (_isRecording && snapshot.hasData) {
                            posX = posX + (snapshot.data!.y * 15);
                            posY = posY + (snapshot.data!.x * 15);

                            if (posY > (dLength/4 + 150)) posY = dLength/4 + 150;
                            if (posY < (dLength/4 - 150)) posY = dLength/4 - 150;
                            if (posX > (dWidth/2 + 150)) posX = dWidth/2 + 150;
                            if (posX < (dWidth/2 - 150)) posX = dWidth/2 - 150;

                            p.drawStart(Offset(posX, posY));
                            p.drawing(Offset(posX, posY));
                          }
                          return Screenshot(
                            controller: controller,
                            child: Scaffold(
                              body: Stack(
                                children: [
                                  Center(child: Icon(Icons.circle ,size: 350,color: Colors.grey,)),
                                  (_isRecording)? Center(child: CircularPercentIndicator(
                                    animation: true,
                                    animationDuration: 20000,
                                    percent: 1.0,
                                    radius: 120,
                                    lineWidth: 30,
                                    progressColor: Colors.white,
                                    backgroundColor: Colors.grey,
                                    circularStrokeCap: CircularStrokeCap.round,
                                  )):Center(),
                                  Center(child: Icon(Icons.circle ,size: 150,color: Colors.white,)),
                                  Positioned.fill(
                                    child:
                                    CustomPaint(painter: DrawingPainter(p.lines)),
                                  ),
                                  Transform.translate(
                                    offset: Offset(posX, posY),
                                    child: const CircleAvatar(
                                      radius: 10,
                                      backgroundColor: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                  ),
                ),
                const SizedBox(height: 5),
                IconButton(
                    iconSize: 50,
                    color: Colors.black,
                    onPressed: (){
                      sendImage();
                      sendfileA();
                      sendfileG();
                      } ,
                    icon: const Icon(Icons.camera_alt_outlined)),
                IconButton(
                    iconSize: 30,
                    color: Colors.black,
                    onPressed: onResetPressed,
                    icon: const Icon(Icons.restart_alt)),
              ],
            ), (loading)? Center(child: CircularProgressIndicator(),):Center()]
        ),
      ),
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isRecording) {
        setState(() {
          _secondsLeft--;
        });
      }

      if (_secondsLeft == 0) {
        _resetTimer();
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

  void onResetPressed() {
    _timer.cancel();
    setState(() {
      _isRecording = false;
      _secondsLeft = 20;
    });
    Navigator.of(context).popUntil((route) => route.isCurrent);
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

  void _resetTimer() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    setState(() {
      _isRecording = false;
      _secondsLeft = 20;
    });
    _printTable();
  }


  // Print the table (data) in the console
  void _printTable() {
    for (var row in _dataStorageA) {
      print(row);
    }
    for (var row in _dataStorageG) {
      print(row);
    }
  }
}

class DrawingPainter extends CustomPainter {
  DrawingPainter(this.lines);
  final List<List<DotInfo>> lines;
  @override
  void paint(Canvas canvas, Size size) {
    for (var oneLine in lines) {
      Color color = Colors.black;
      double size = 5;
      var l = <Offset>[];
      var p = Path();
      for (var oneDot in oneLine) {
        color = oneDot.color;
        size = oneDot.size;
        l.add(oneDot.offset);
      }
      p.addPolygon(l, false);
      canvas.drawPath(
          p,
          Paint()
            ..color = color
            ..strokeWidth = size
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
