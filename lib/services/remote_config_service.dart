import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

class RemoteConfigService {
  static final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  static Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(seconds: 0),
    ));
    await _remoteConfig.setDefaults(<String, dynamic>{
      'block_color': '#23695C',
      'add_balance_enabled': true,
    });
    try {
      final bool updated = await _remoteConfig.fetchAndActivate();
      print('RemoteConfig updated: $updated');
    } catch (e) {
      print('RemoteConfig error: $e');
    }
  }

  static Future<void> forceFetch() async {
    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      print('RemoteConfig forceFetch error: $e');
    }
  }

  static Color getBlockColor() {
    try {
      final colorString = _remoteConfig.getString('block_color');
      return _hexToColor(colorString);
    } catch (e) {
      print('Error getting block color: $e');
      return _hexToColor('#23695C'); // Fallback color
    }
  }

  static bool isAddBalanceEnabled() {
    try {
      return _remoteConfig.getBool('add_balance_enabled');
    } catch (e) {
      print('Error getting add_balance_enabled: $e');
      return true; // Fallback value
    }
  }

  static Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}