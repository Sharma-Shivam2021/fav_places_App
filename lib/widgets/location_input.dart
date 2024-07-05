import 'dart:convert';
import 'package:favourite_place/models/place.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onPickLocation});
  final void Function(PlaceLocation placeLocation) onPickLocation;

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  Location location = Location();
  bool? _serviceEnabled;
  PermissionStatus? _permissionStatus;
  LocationData? _locationData;
  bool _isGettingLocation = false;
  String address = '';
  PlaceLocation? _pickedLocation;

  String get locationImage {
    final lat = _pickedLocation!.latitude;
    final lng = _pickedLocation!.longitude;
    return 'https://maps.geoapify.com/v1/staticmap?style=osm-bright-smooth&width=600&height=400&center=lonlat:$lng,$lat&marker=lonlat:$lng,$lat&zoom=6&apiKey=API KEY';
  }

  Future<bool> _checkLocationService() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled!) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled!) {
        return false;
      }
    }
    return true;
  }

  Future<bool> _checkLocationPermission() async {
    _permissionStatus = await location.hasPermission();
    if (_permissionStatus == PermissionStatus.denied) {
      _permissionStatus = await location.requestPermission();
      if (_permissionStatus == PermissionStatus.denied) {
        return false;
      }
    }
    return true;
  }

  void _getCurrentLocation() async {
    final locationService = await _checkLocationService();
    final locationPermission = await _checkLocationPermission();
    if (locationService == false) {
      return;
    }
    if (locationPermission == false) {
      return;
    }
    setState(() {
      _isGettingLocation = true;
    });
    _locationData = await location.getLocation();

    final uri = Uri.parse(
        'http://api.openweathermap.org/geo/1.0/reverse?lat=${_locationData!.latitude}&lon=${_locationData!.longitude}&appid=API KEY');
    final http.Response resData = await http.get(uri);
    final data = json.decode(resData.body);
    address = "${data[0]["name"]}, ${data[0]["state"]}, ${data[0]["country"]}";

    setState(() {
      _pickedLocation = PlaceLocation(
        latitude: _locationData!.latitude,
        longitude: _locationData!.longitude,
        address: address,
      );
      _isGettingLocation = false;
    });
    widget.onPickLocation(_pickedLocation!);
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text(
      address.isNotEmpty ? address : 'No location chosen',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Theme.of(context).colorScheme.onBackground,
          ),
    );
    if (_pickedLocation != null) {
      previewContent = Image.network(
        locationImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    if (_isGettingLocation) {
      previewContent = const CircularProgressIndicator();
    }
    return Column(
      children: [
        Container(
          height: 170,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
          ),
          alignment: Alignment.center,
          child: previewContent,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: () {
                _getCurrentLocation();
              },
              icon: const Icon(Icons.location_on),
              label: const Text('Get Current Location'),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.map),
              label: const Text('Select on Map'),
            ),
          ],
        )
      ],
    );
  }
}
