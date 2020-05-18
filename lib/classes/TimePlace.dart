import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:whereuapp/servises/firestore.dart';

class TimePlace implements Comparable <TimePlace>{
  LatLng _location;
  DateTime _date;
  final FirestoreService _firestoreService = FirestoreService();
  //Constructor
  TimePlace (LatLng position,DateTime dateTime){
    this._location = position;
    this._date = dateTime;
  }
  TimePlace.fromMap (Map<String,dynamic> data){
      GeoPoint geoPoint = data['Location'];
      this._location = LatLng(geoPoint.latitude, geoPoint.longitude);
      Timestamp date = data['Date'];
      this._date = date.toDate();
  }
  Map<String,dynamic> TimePlaceToMAp (){
    return {
      'Location' : GeoPoint(location.latitude, location.longitude),
      'Date' : _firestoreService.firestoreDateTime(this._date),
    };
  }
  //Getters
  DateTime get date => _date;

  LatLng get location => _location;

  @override
  int compareTo(TimePlace other) {
    return this._date.compareTo(other.date);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TimePlace &&
              runtimeType == other.runtimeType &&
              _date == other._date;

  @override
  int get hashCode => _date.hashCode;
}