import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

class AppPermissions {
  AppPermissions() {
    getLocationPermission();
  }

  // Check and request location permission
  static Future<bool> getLocationPermission() async {
    PermissionStatus status = await Permission.location.status;
    debugPrint("Location STATUS: $status");
    if (status.isDenied || status.isPermanentlyDenied) {
      PermissionStatus newStatus = await Permission.location.request();
      debugPrint("Location STATUS AFTER ASK: $newStatus");
      return newStatus.isGranted;
    }
    return status.isGranted;
  }

  // Check and request camera permission
  static Future<bool> getCameraPermission() async {
    PermissionStatus status = await Permission.camera.status;
    debugPrint("Camera STATUS: $status");
    if (status.isDenied || status.isPermanentlyDenied) {
      PermissionStatus newStatus = await Permission.camera.request();
      debugPrint("Camera STATUS AFTER ASK: $newStatus");
      return newStatus.isGranted;
    }
    return status.isGranted;
  }

  // static void requestLocationPermissions() {
  //   final permissions = [PermissionType.accessLocation];
  //   permissionManager.tryToRequest(permissions);
  //   permissionManager.showRequestDialog(permissions);
  // }

  // Check and request gallery permission
  static Future<bool> getGalleryPermission() async {
    // Use Permission.photos for iOS and Android 13+
    // Use Permission.storage as fallback for Android < 13
    PermissionStatus status;
    if (Platform.isAndroid) {
      // Check Android version for appropriate permission
      if (await Permission.photos.isRestricted) {
        // Android 13+: Use photos permission
        status = await Permission.photos.status;
      } else {
        // Android < 13: Use storage permission
        status = await Permission.storage.status;
      }
    } else {
      // iOS: Use photos permission
      status = await Permission.photos.status;
    }

    debugPrint("Gallery STATUS: $status");
    if (status.isDenied || status.isPermanentlyDenied) {
      PermissionStatus newStatus;
      if (Platform.isAndroid && await Permission.photos.isRestricted) {
        newStatus = await Permission.photos.request();
      } else {
        newStatus = await (Platform.isAndroid
            ? Permission.storage
            : Permission.photos).request();
      }
      debugPrint("Gallery STATUS AFTER ASK: $newStatus");
      return newStatus.isGranted;
    }
    return status.isGranted;
  }
}