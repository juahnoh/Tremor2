import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter/material.dart';
import '../../../../dotinfo.dart';
import 'package:path_provider/path_provider.dart';

class DrawingProvider extends ChangeNotifier{

  final lines = <List<DotInfo>>[];
  double size =5;
  Color color = Colors.black;

  void drawStart(Offset offset){
    var oneLine = <DotInfo>[];
    oneLine.add(DotInfo(offset, size, color));
    lines.add(oneLine);
  }
  void drawing(Offset offset){
    lines.last.add(DotInfo(offset, size, color));
  }
}