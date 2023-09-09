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

  bool _accelAvailable = false;
  List<double> _accelData = List.filled(3, 0.0);
  StreamSubscription? _accelSubscription;
  final List<List<dynamic>> _dataStorage = [];

  bool loading = false;

  FirebaseStorage storage = FirebaseStorage.instance;

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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dWidth = MediaQuery.of(context).size.width;
    dLength = MediaQuery.of(context).size.height;
    posX = dWidth/2 ;
    posY = dLength/4;
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
                      } else {
                        _startTimer();
                        _isRecording = true;
                      }
                    });
                  },
                ),
                Text(
                  '00:${_secondsLeft.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 20),
                ),
                Screenshot(
                  controller: controller,
                  child: SizedBox(
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
                            return Scaffold(
                              body: Stack(
                                children: [
                                  Center(child: Icon(Icons.circle ,size: 350,color: Colors.grey,)),
                                  Center(child: Icon(Icons.circle ,size: 150,color: Colors.white,)),
                                  Positioned.fill(
                                    child:
                                    CustomPaint(painter: DrawingPainter(p.lines)),
                                  ),
                                  Transform.translate(
                                    offset: Offset(posX, posY),
                                    child: const CircleAvatar(
                                      radius: 5,
                                      backgroundColor: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                IconButton(
                    iconSize: 50,
                    color: Colors.black,
                    onPressed: (){sendImage();} ,
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
      _secondsLeft = 60;
    });
    Navigator.of(context).popUntil((route) => route.isCurrent);
  }



  void _resetTimer() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    setState(() {
      _isRecording = false;
      _secondsLeft = 60;
    });
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
