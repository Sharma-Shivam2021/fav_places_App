import 'dart:io';

import 'package:uuid/uuid.dart';

const uid = Uuid();

class PlaceLocation {
  PlaceLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  final double? latitude;
  final double? longitude;
  final String address;
}

class Places {
  Places({
    required this.title,
    required this.image,
    required this.location,
    String? id,
  }) : id = id ?? uid.v4();
  final String id;
  final String title;
  final File image;
  final PlaceLocation location;
}
