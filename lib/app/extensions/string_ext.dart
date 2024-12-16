import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

extension FIELD on String {
  static final RegExp phoneReg = RegExp(r'^9\d{9}$');
  static final RegExp emailReg = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  bool isValidPhoneNumber() => phoneReg.hasMatch(this);
  bool isValidEmail() => emailReg.hasMatch(this);
}

extension PARSER on String {
  Uri get toUri => Uri.parse(this);
  String obscureEmail() {
    // Split the email into username and domain
    final parts = split('@');
    if (parts.length != 2) {
      return this; // Return original email if it's invalid
    }

    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 2) {
      // If the username is too short, handle it specially
      return '${username[0]}*@${domain}';
    }

    // Obscure the middle part of the username
    final firstLetter = username[0];
    final lastLetter = username[username.length - 1];
    final obscuredUsername = firstLetter +
        '*' * (username.length - 2) +
        lastLetter; // Replace middle characters with *

    return '$obscuredUsername@$domain';
  }

  TimeOfDay get toTimeOfDay {
    final List<int> ff = split(':').map((e) => int.parse(e)).toList();
    return TimeOfDay(hour: ff.first, minute: ff[1]);
  }

  GeoPoint toGeopoint() {
    List<String> coords = split(',');

    if (coords.length != 2) {
      throw FormatException(
          'Invalid geoString format. Expected "latitude,longitude".');
    }
    // Parse the latitude and longitude from the string
    double latitude = double.parse(coords[0].trim());
    double longitude = double.parse(coords[1].trim());
    return GeoPoint(latitude, longitude);
  }
}

extension CAPITALIZER on String {
  String capitalize() =>
      "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  String capitalizeWords() {
    try {
      List<String> words = split(" ");
      for (int i = 0; i < words.length; i++) {
        String word = words[i];
        if (word.isNotEmpty) {
          words[i] = "${word[0].toUpperCase()}${word.substring(1)}";
        }
      }
      return words.join(" ");
    } catch (e, s) {
      return this;
    }
  }
}

extension CONVERT on String {
  String hexToColorName() {
    String hexColor = this;
    hexColor = hexColor.replaceFirst('#', '').toLowerCase();

    // Parse the hex value to get RGB components
    int hexInt = int.parse(hexColor, radix: 16);
    int r = (hexInt >> 16) & 0xFF; // Red
    int g = (hexInt >> 8) & 0xFF; // Green
    int b = hexInt & 0xFF; // Blue

    // Determine the color name based on RGB values
    if (r == 0 && g == 0 && b == 0) {
      return 'Black'; // Black
    } else if (r == 255 && g == 255 && b == 255) {
      return 'White'; // White
    } else if (r == g && g == b) {
      return 'Gray'; // Shades of gray
    } else if (r > g && r > b) {
      return 'Red'; // Any shade of red
    } else if (g > r && g > b) {
      return 'Green'; // Any shade of green
    } else if (b > r && b > g) {
      return 'Blue'; // Any shade of blue
    } else if (r > g && b > g) {
      return 'Purple'; // Purple shades
    } else if (r > 200 && g > 100 && b < 100) {
      return 'Orange'; // Orange shades
    } else if (g > 200 && b < 100 && r < 100) {
      return 'Yellow'; // Yellow shades
    }

    return 'Unknown'; // If no category matched
  }
}
