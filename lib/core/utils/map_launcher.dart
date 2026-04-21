import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

class MapOption {
  final String name;
  final String scheme;
  final IconData icon;

  MapOption({required this.name, required this.scheme, required this.icon});
}

class MapLauncher {
  static Future<void> showMapSelectionDialog(
      BuildContext context,
      double latitude,
      double longitude, {
        String? label,
      }) async {
    final mapOptions = [
      MapOption(
        name: 'Apple Maps',
        scheme: 'maps:$latitude,$longitude?q=$latitude,$longitude',
        icon: Icons.map,
      ),
      MapOption(
        name: 'Google Maps',
        scheme: 'comgooglemaps://?q=$latitude,$longitude',
        icon: Icons.place,
      ),
      MapOption(
        name: 'Yandex Maps',
        scheme: 'yandexmaps://maps.yandex.ru/?pt=$longitude,$latitude&z=16',
        icon: Icons.location_on,
      ),
      MapOption(
        name: 'Waze',
        scheme: 'waze://?ll=$latitude,$longitude&navigate=yes',
        icon: Icons.navigation,
      ),
      MapOption(
        name: '2GIS',
        scheme: 'dgis://2gis.ru/geo/$longitude,$latitude',
        icon: Icons.map_outlined,
      ),
    ];

    // Check which apps are available
    final availableApps = <MapOption>[];
    for (final option in mapOptions) {
      if (await _canLaunchUrl(option.scheme)) {
        availableApps.add(option);
      }
    }

    if (!context.mounted) return;

    if (availableApps.isEmpty) {
      // Fallback to web browser with Google Maps
      await _launchWebMap(latitude, longitude, label);
      return;
    }

    // Show Cupertino action sheet
    await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: const Text('Xarita ilovasini tanlang'),
          message: const Text('Manzilni qaysi xarita ilovasida ochmoqchisiz?'),
          actions: availableApps.map((option) {
            return CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).pop();
                _launchMap(context, option.scheme);
              },
              child: Text(option.name),
            );
          }).toList(),
          cancelButton: CupertinoActionSheetAction(
            isDestructiveAction: false,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Bekor qilish'),
          ),
        );
      },
    );
  }

  static Future<bool> _canLaunchUrl(String urlString) async {
    try {
      final url = Uri.parse(urlString);
      return await canLaunchUrl(url);
    } catch (e) {
      return false;
    }
  }

  static Future<void> _launchMap(BuildContext context, String urlString) async {
    try {
      final url = Uri.parse(urlString);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Could not launch $urlString';
      }
    } catch (error) {
      if (context.mounted) {
        _showErrorDialog(context, error.toString());
      }
    }
  }

  static Future<void> _launchWebMap(
      double latitude,
      double longitude,
      String? label,
      ) async {
    final query = label != null ? Uri.encodeComponent(label) : '$latitude,$longitude';
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude&query_place_id=$query',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  static void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to open map: $error'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Alternative method: Launch specific map directly
  static Future<void> launchAppleMaps(
      BuildContext context,
      double latitude,
      double longitude,
      ) async {
    final url = Uri.parse('maps:$latitude,$longitude?q=$latitude,$longitude');
    await _launchMap(context, url.toString());
  }

  static Future<void> launchGoogleMaps(
      BuildContext context,
      double latitude,
      double longitude,
      ) async {
    final url = Uri.parse('comgooglemaps://?q=$latitude,$longitude');
    await _launchMap(context, url.toString());
  }

  static Future<void> launchYandexMaps(
      BuildContext context,
      double latitude,
      double longitude,
      ) async {
    final url = Uri.parse('yandexmaps://maps.yandex.ru/?pt=$longitude,$latitude&z=16');
    await _launchMap(context, url.toString());
  }
}