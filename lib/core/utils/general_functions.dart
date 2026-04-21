import 'dart:io';
import 'dart:math';

import 'package:bonoos/core/api/dio_client.dart';
import 'package:bonoos/core/extension/for_context.dart';
import 'package:bonoos/generated/l10n.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'enums.dart';

class MyFunctions {
  static String localDateFormat(DateTime date, {String format = "dd.MM.yyyy HH:mm"}) {
    return DateFormat(format).format(date);
  }

  static Future<XFile?> compressImage(File image) async {
    final tempDir = await Directory.systemTemp.createTemp();
    final compressedPath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    return await FlutterImageCompress.compressAndGetFile(
      image.path,
      compressedPath,
      quality: 70,
      minWidth: 512,
      minHeight: 512,
    );
  }


  static Future<bool> uploadToPresignedUrl(String url, XFile file, DioClient dioClient) async {
    final bytes = await file.readAsBytes();
    final response = await dioClient.put(
      url,
      data: bytes,
      options: Options(
        headers: {'Content-Type': 'image/jpeg'},
        responseType: ResponseType.plain,
        contentType: "image/jpeg",
      ),
    );

    print("Upload to presigned URL response status code: ${response.statusCode}");

    return response.statusCode == 200;
  }

  // Function to determine card type based on card number
  static CardType getCardType(String cardNumber) {
    // Remove any spaces or special characters
    final cleanNumber = cardNumber.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanNumber.isEmpty) return CardType.unknown;

    // Check for UzCard (starts with 8600, 5614, 6262)
    if (cleanNumber.startsWith('8600') || cleanNumber.startsWith('5614') || cleanNumber.startsWith('6262')) {
      return CardType.uzcard;
    }

    // Check for Visa (starts with 4)
    if (cleanNumber.startsWith('4')) {
      return CardType.visa;
    }

    // Check for Mastercard (starts with 5)
    if (cleanNumber.startsWith('5')) {
      return CardType.mastercard;
    }

    // Check for Humo (starts with 9860, 6440)
    if (cleanNumber.startsWith('9860') || cleanNumber.startsWith('6440')) {
      return CardType.humo;
    }

    return CardType.unknown;
  }

  // Function to get appropriate icon based on card type
  static String getCardIcon(CardType cardType) {
    switch (cardType) {
      case CardType.visa:
        return "";
      case CardType.mastercard:
        return ""; // Adjust to your actual icon name
      case CardType.uzcard:
        return "";
      case CardType.humo:
        return ""; // Adjust to your actual icon name
      case CardType.unknown:
        return ""; // Fallback icon
    }
  }

  // Function to mask card number for display
  static String maskCardNumber(String cardNumber) {
    if (cardNumber.length < 4) return cardNumber;

    final last4 = cardNumber.substring(cardNumber.length - 4);
    final first4 = cardNumber.length >= 4 ? cardNumber.substring(0, 4) : '';

    return '$first4 **** **** $last4';
  }

  static String getVolumeText(double volume) {
    const thresholds = {
      "1.0": 0.8, // Max volume for values >= 0.8
      "0.6": 0.4, // Medium volume for values >= 0.4 and < 0.8
      "0.3": 0.2, // Low volume for values >= 0.2 and < 0.4
      "0.0": 0.0, // Mute for values < 0.2
    };

    if (volume >= thresholds["1.0"]!) return "Максимум";
    if (volume >= thresholds["0.6"]!) return "Средний";
    if (volume >= thresholds["0.3"]!) return "Тихий";
    return "Выключить";
  }

  static String themeName(ThemeModeState mode, BuildContext context) {
    switch (mode) {
      case ThemeModeState.light:
        return context.tr.light; // "Light"
      case ThemeModeState.dark:
        return S.of(context).dark; // "Dark"
      case ThemeModeState.auto:
        return S.of(context).auto; // "Auto"
    }
  }

  static String languageName(String code, BuildContext context) {
    switch (code) {
      case 'uz':
        return "O'zbek"; // ""
      case 'ru':
        return "Русский";
      case 'es':
        return "Кирилча";
      case 'en':
      default:
        return "English"; // "English"
    }
  }

  static List<List<double>> generatePentagon(double lat, double lon, double radiusInMeters) {
    const int sides = 5;
    const double earthRadius = 6371000; // metrda
    final List<List<double>> coordinates = [];

    double centerLatRad = lat * pi / 180;
    double centerLonRad = lon * pi / 180;

    for (int i = 0; i <= sides; i++) {
      double angleDeg = 72.0 * i; // 360 / 5 = 72
      double angleRad = angleDeg * pi / 180;

      double latRad = asin(
        sin(centerLatRad) * cos(radiusInMeters / earthRadius) +
            cos(centerLatRad) * sin(radiusInMeters / earthRadius) * cos(angleRad),
      );

      double lonRad =
          centerLonRad +
          atan2(
            sin(angleRad) * sin(radiusInMeters / earthRadius) * cos(centerLatRad),
            cos(radiusInMeters / earthRadius) - sin(centerLatRad) * sin(latRad),
          );

      double pointLat = latRad * 180 / pi;
      double pointLon = lonRad * 180 / pi;

      coordinates.add([pointLon, pointLat]); // long, lat formatida
    }

    return coordinates;
  }

  static List<List<double>> generateHexagon(double centerLat, double centerLon, double radiusInMeters) {
    const double earthRadius = 6371000;
    List<List<double>> hexagonPoints = [];

    // Generate 6 vertices of hexagon
    for (int i = 0; i < 6; i++) {
      double angleDeg = (60 * i).toDouble();
      double angleRad = pi / 180 * angleDeg;

      // Calculate offset in meters
      double deltaX = radiusInMeters * cos(angleRad);
      double deltaY = radiusInMeters * sin(angleRad);

      // Convert to lat/lon offsets
      double deltaLat = (deltaY / earthRadius) * (180 / pi);
      double deltaLon = (deltaX / (earthRadius * cos(pi * centerLat / 180))) * (180 / pi);

      // Calculate vertex coordinates
      double vertexLat = centerLat + deltaLat;
      double vertexLon = centerLon + deltaLon;

      hexagonPoints.add([vertexLon, vertexLat]);
    }

    // Close the polygon by adding the first point at the end
    hexagonPoints.add(hexagonPoints[0]);

    return hexagonPoints;
  }

  static List<List<List<double>>> generateHexGrid(
    double centerLat,
    double centerLon,
    double radiusInMeters,
    int rows,
    int cols,
  ) {
    const double earthRadius = 6371000;
    final double hexWidth = sqrt(3) * radiusInMeters;
    final double hexHeight = 1.5 * radiusInMeters;
    List<List<List<double>>> hexagons = [];

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        double offsetX = col * hexWidth;
        double offsetY = row * hexHeight;

        // Qatorlar orasida siljitish (staggered rows)
        if (row % 2 == 1) {
          offsetX += hexWidth / 2;
        }

        // Koordinatani geolokatsiyaga aylantirish
        double dLat = (offsetY / earthRadius) * (180 / pi);
        double dLon = (offsetX / (earthRadius * cos(pi * centerLat / 180))) * (180 / pi);

        double hexCenterLat = centerLat + dLat;
        double hexCenterLon = centerLon + dLon;

        final hex = generateHexagon(hexCenterLat, hexCenterLon, radiusInMeters);
        hexagons.add(hex);
      }
    }

    return hexagons;
  }

  static String parseAndFormatDate(
    String dateString, {
    String inputFormat = "yyyy-MM-dd'T'HH:mm:ss",
    String outputFormat = "dd.MM.yyyy HH:mm",
  }) {
    try {
      final inputFormatter = DateFormat(inputFormat);
      final dateTime = inputFormatter.parse(dateString);

      final outputFormatter = DateFormat(outputFormat);
      return outputFormatter.format(dateTime);
    } catch (e) {
      return 'Invalid date format';
    }
  }

  static String getPhone(text) {
    return text.replaceAll("-", "").replaceAll("(", "").replaceAll(")", "").replaceAll(" ", "");
  }

  static String formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.length != 9) {
      throw const FormatException("Phone number should be exactly 9 digits long");
    }

    String areaCode = phoneNumber.substring(0, 2);
    String part1 = phoneNumber.substring(2, 5);
    String part2 = phoneNumber.substring(5, 7);
    String part3 = phoneNumber.substring(7, 9);

    return '($areaCode) $part1-$part2-$part3';
  }

  // Function to dial a phone number
  static dialPhoneNumber(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      await launchUrl(launchUri);
    } on PlatformException catch (e) {
      // Handle exception if the device cannot handle the dialer
      debugPrint('Error launching dialer: $e');
    }
  }

  static launchMyUrl(String url) async {
    final Uri launchUri = Uri.parse(url);
    try {
      await launchUrl(launchUri);
    } on PlatformException catch (e) {
      // Handle exception if the device cannot handle the dialer
      debugPrint('Error launching : $e');
    }
  }

  static lauchMapOnIOS(BuildContext context, double latitude, double longitude) async {
    try {
      final url = Uri.parse('maps:$latitude,$longitude?q=$latitude,$longitude');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (error) {
      if (context.mounted) {
        // Util.showErrorDialog(context: context, error: error.toString());
      }
    }
  }

  static launchMapOnAndroid(BuildContext context, double latitude, double longitude) async {
    try {
      const String markerLabel = 'Here';
      final url = Uri.parse('geo:$latitude,$longitude?q=$latitude,$longitude($markerLabel)');
      await launchUrl(url);
    } catch (error) {
      if (context.mounted) {
        // Util.showErrorDialog(context: context, error: error.toString());
      }
    }
  }

  // Function to share information
  static onShareTap(String content) {
    Share.share(content);
  }

  static Future<void> shareImageAndTitle({String? imageUrl, required String title}) async {
    try {
      final cachedFile = await DefaultCacheManager().getSingleFile(imageUrl ?? '');

      if (cachedFile.existsSync()) {
        await SharePlus.instance.share(ShareParams(files: [XFile(cachedFile.path)], text: title));
      } else {
        debugPrint('No cached image found.');
      }
    } catch (e) {
      debugPrint('Error sharing cached image: $e');
    }
  }
}
