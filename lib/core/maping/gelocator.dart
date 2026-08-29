import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // 1. Check if location services are enabled on the device.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  // 2. Check current permission status.
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied.');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.',
    );
  }

  // 3. When permissions are granted, fetch the current position.
  return await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
  );
}

// geocoding ^5.0.0 uses an instance-based API again:
//   final Geocoding geocoding = Geocoding();
//   await geocoding.placemarkFromCoordinates(lat, lng);
// (Earlier 3.x/4.x versions exposed placemarkFromCoordinates as a
// top-level function instead — if you ever downgrade, this call
// site needs to change back.)
final Geocoding _geocoding = Geocoding();

Future<String> getAreaName() async {
  try {
    // 1. Get coordinates
    Position position = await determinePosition();

    // 2. Convert coordinates to placemarks
    List<Placemark> placemarks = await _geocoding.placemarkFromCoordinates(
      position.latitude,
      position.longitude,
      // locale: const Locale('ar'),
    );
debugPrint("Coordinates: lat=${position.latitude}, lng=${position.longitude}");
    Placemark place = placemarks[0];

    // 3. Restrict to Egypt only
    String country = place.country ?? "";
    // isoCountryCode is more reliable than the country name (which can
    // come back localized, e.g. "مصر" instead of "Egypt").
    String isoCountryCode = place.isoCountryCode ?? "";
    bool isEgypt =
        isoCountryCode.toUpperCase() == "EG" ||
        country.toLowerCase() == "egypt" ||
        country == "مصر";

    if (!isEgypt) {
      return Future.error(
        "الخدمة متاحة داخل مصر فقط. الموقع الحالي: ${country.isNotEmpty ? country : 'غير معروف'}",
      );
    }

    // 4. Build address safely, excluding the country since we already
    // know it's Egypt. Different regions populate different fields, so
    // fall back through several before giving up.
    debugPrint('Placemark: $place');

    String subLocality = place.subLocality ?? "";
    String locality = place.locality ?? "";
    String subAdministrativeArea = place.subAdministrativeArea ?? "";
    String administrativeArea = place.administrativeArea ?? "";
    String thoroughfare = place.thoroughfare ?? "";
    String name = place.name ?? "";

    List<String> addressParts = [
      subLocality,
      locality,
      subAdministrativeArea,
      administrativeArea,
    ].where((part) => part.isNotEmpty).toList();

    String areaName = addressParts.join(', ');

    if (areaName.isEmpty) {
      // Last resort: use whatever the geocoder considered the "name"
      // or the street, rather than an unhelpful "unknown" message.
      areaName = name.isNotEmpty
          ? name
          : (thoroughfare.isNotEmpty ? thoroughfare : "");
    }

    return areaName.isNotEmpty ? areaName : "عنوان غير معروف";
  } catch (e) {
    return Future.error("فشل في تحديد اسم المنطقة: $e");
  }
}

class LocationWidget extends StatefulWidget {
  const LocationWidget({super.key});

  @override
  State<LocationWidget> createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  String _locationMessage = "Press the button to get location";
  bool _isLoading = false;

  Future<void> _getLocationName() async {
    setState(() {
      _isLoading = true;
    });
    try {
      String area = await getAreaName();
      setState(() {
        _locationMessage = "أنت الآن في: $area";
        print("Current Area: $area");
      });
    } catch (e) {
      setState(() {
        _locationMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(_locationMessage, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _getLocationName,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Get Current Location"),
            ),
          ],
        ),
      ),
    );
  }
}
