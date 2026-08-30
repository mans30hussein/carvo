import 'package:carvo/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

 
// geocoding ^5.0.0 uses an instance-based API (Geocoding().placemarkFromCoordinates)
// rather than the old top-level placemarkFromCoordinates() function.
final Geocoding _geocoding = Geocoding();

/// An [AppTextField] specialised for address input.
///
/// Tapping the leading icon resolves the device's current GPS position,
/// reverse-geocodes it into a human-readable address, and fills the
/// field with the result. Handles permission requests, disabled
/// location services, and failures with a [SnackBar].
class LocationAddressField extends StatefulWidget {
  const LocationAddressField({
    super.key,
    required this.controller,
    required this.label,
    this.maxLines = 2,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;

  @override
  State<LocationAddressField> createState() => _LocationAddressFieldState();
}

class _LocationAddressFieldState extends State<LocationAddressField> {
  bool _isResolving = false;

  Future<void> _resolveCurrentLocation() async {
    if (_isResolving) return;
    setState(() => _isResolving = true);

    try {
      final position = await _determinePosition();
      final address = await _addressFromPosition(position);
      widget.controller.text = address;
    } on _LocationServiceDisabled {
      _showError('Location services are disabled. Please enable them.');
    } on _LocationPermissionDenied catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Could not determine your location. Please try again.');
    } finally {
      if (mounted) setState(() => _isResolving = false);
    }
  }

  Future<Position> _determinePosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw _LocationServiceDisabled();
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw _LocationPermissionDenied('Location permission was denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw _LocationPermissionDenied(
        'Location permission is permanently denied. Enable it from app settings.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  Future<String> _addressFromPosition(Position position) async {
    final placemarks = await _geocoding.placemarkFromCoordinates(
      position.latitude,
      position.longitude,
      locale: const Locale('ar'), // Use English for consistency
    );

    if (placemarks.isEmpty) {
      return '${position.latitude}, ${position.longitude}';
    }

    final place = placemarks.first;
    final parts = [
      place.subLocality,
      place.locality,
      place.subAdministrativeArea,
      place.administrativeArea,
    ].where((part) => part != null && part.trim().isNotEmpty);

    return parts.isEmpty
        ? '${position.latitude}, ${position.longitude}'
        : parts.join(', ');
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      label: widget.label,
      icon: _isResolving ? Icons.hourglass_top_rounded : Icons.location_on_outlined,
      maxLines: widget.maxLines,
      onPressed: _resolveCurrentLocation,
    );
  }
}

class _LocationServiceDisabled implements Exception {}

class _LocationPermissionDenied implements Exception {
  _LocationPermissionDenied(this.message);
  final String message;
}