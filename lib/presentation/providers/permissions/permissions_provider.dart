import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

// state notifier provider

// provider
final permissionsProvider =
    StateNotifierProvider<PermissionsNotifier, PermissionState>((ref) {
  return PermissionsNotifier();
});

// notifier
class PermissionsNotifier extends StateNotifier<PermissionState> {
  PermissionsNotifier() : super(PermissionState()){
    checkPermissions();
  }

  Future<void> checkPermissions() async {
    final isAndroidVersionLowerThan30 = await _platformVersion();
    final permissionsArray = await Future.wait([
      Permission.camera.status,
      isAndroidVersionLowerThan30
          ? Permission.storage.status
          : Permission.photos.status,
      Permission.sensors.status,
      Permission.location.status,
      Permission.locationAlways.status,
      Permission.locationWhenInUse.status,
    ]);

    state = state.copyWith(
      camera: permissionsArray[0],
      photosLibrary: permissionsArray[1],
      sensors: permissionsArray[2],
      
      location: permissionsArray[3],
      locationAlways: permissionsArray[4],
      locationWhenInUse: permissionsArray[5],
    );
  }

  openSettingsScreen() {
    openAppSettings();
  }

  void _checkPermissionState(PermissionStatus status) {
    if (status == PermissionStatus.permanentlyDenied) {
      openSettingsScreen();
    }
  }

  requestCameraAccess() async {
    final status = await Permission.camera.request();
    state = state.copyWith(camera: status);

    _checkPermissionState(status);
  }

  requestLibraryPhotosAccess() async {
    if (Platform.isAndroid) {
      final isAndroidVersionLowerThan30 = await _platformVersion();
      if (isAndroidVersionLowerThan30) {
        final status = await Permission.storage.request();
        state = state.copyWith(photosLibrary: status);
        if (status.isPermanentlyDenied) {
          _openSettings(status);
        }
      } else {
        final status = await Permission.photos.request();
        state = state.copyWith(photosLibrary: status);
 
        if (status.isPermanentlyDenied) {
          _openSettings(status);
        }
      }
    } else {
      final status = await Permission.photos.request();
      state = state.copyWith(photosLibrary: status);
      _openSettings(status);
    }
  }

  void _openSettings(PermissionStatus status) {
    if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<bool> _platformVersion() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    return androidInfo.version.sdkInt < 30;
  }

  requestLocationAccess() async {
    final status = await Permission.location.request();
    state = state.copyWith(location: status);

    _checkPermissionState(status);
  }

  requestSensorAccess() async {
    final status = await Permission.sensors.request();
    state = state.copyWith(sensors: status);

    _checkPermissionState(status);
  }
}

// state
class PermissionState {
  final PermissionStatus camera;
  final PermissionStatus photosLibrary;
  final PermissionStatus sensors;

  final PermissionStatus location;
  final PermissionStatus locationAlways;
  final PermissionStatus locationWhenInUse;

  PermissionState({
    this.camera = PermissionStatus.denied,
    this.photosLibrary = PermissionStatus.denied,
    this.sensors = PermissionStatus.denied,
    this.location = PermissionStatus.denied,
    this.locationAlways = PermissionStatus.denied,
    this.locationWhenInUse = PermissionStatus.denied,
  });

  get cameraGranted {
    return camera == PermissionStatus.granted;
  }

  get photosLibraryGranted {
    return photosLibrary == PermissionStatus.granted;
  }

  get sensorsGranted {
    return sensors == PermissionStatus.granted;
  }

  get locationGranted {
    return location == PermissionStatus.granted;
  }

  get locationAlwaysGranted {
    return locationAlways == PermissionStatus.granted;
  }

  get locationWhenInUseGranted {
    return locationWhenInUse == PermissionStatus.granted;
  }

  PermissionState copyWith({
    PermissionStatus? camera,
    PermissionStatus? photosLibrary,
    PermissionStatus? sensors,
    PermissionStatus? location,
    PermissionStatus? locationAlways,
    PermissionStatus? locationWhenInUse,
  }) {
    return PermissionState(
      camera: camera ?? this.camera,
      photosLibrary: photosLibrary ?? this.photosLibrary,
      sensors: sensors ?? this.sensors,
      location: location ?? this.location,
      locationAlways: locationAlways ?? this.locationAlways,
      locationWhenInUse: locationWhenInUse ?? this.locationWhenInUse,
    );
  }
}
