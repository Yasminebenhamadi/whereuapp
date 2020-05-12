import 'dart:ui';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PinInformation {
  String pinPath;
  String avatarPath;
  String locationName;
  Color labelColor;

  PinInformation({this.pinPath, this.avatarPath, this.locationName, this.labelColor});
}