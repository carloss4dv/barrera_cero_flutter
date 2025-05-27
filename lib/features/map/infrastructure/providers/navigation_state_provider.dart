import 'package:flutter/material.dart';

class NavigationStateProvider extends ChangeNotifier {
  bool _isOnMainMap = true;
  bool _isMarkerDetailVisible = false;

  bool get isOnMainMap => _isOnMainMap;
  bool get isMarkerDetailVisible => _isMarkerDetailVisible;
  bool get shouldShowFloatingButtons => _isOnMainMap && !_isMarkerDetailVisible;

  void setOnMainMap(bool isOnMainMap) {
    if (_isOnMainMap != isOnMainMap) {
      _isOnMainMap = isOnMainMap;
      notifyListeners();
    }
  }

  void setMarkerDetailVisible(bool isVisible) {
    if (_isMarkerDetailVisible != isVisible) {
      _isMarkerDetailVisible = isVisible;
      notifyListeners();
    }
  }

  void navigatedToMenu() {
    setOnMainMap(false);
  }

  void navigatedBackToMap() {
    setOnMainMap(true);
  }
}
