import 'package:nirvana_desktop/models/models.dart';

class HistoryService {
  final List<RouteEntry> _history = [];
  int _currentIndex = -1;

  void push(RouteEntry route, {bool truncateForward = true}) {
    if (truncateForward && _currentIndex < _history.length - 1) {
      _history.removeRange(_currentIndex + 1, _history.length);
    }

    // Avoid duplicate push
    if (_history.isEmpty || _history[_currentIndex] != route) {
      _history.add(route);
      _currentIndex = _history.length - 1;
    }
  }

  RouteEntry? goBack() {
    if (_currentIndex > 0) {
      _currentIndex--;
      return _history[_currentIndex];
    }
    return null;
  }

  RouteEntry? goForward() {
    if (_currentIndex < _history.length - 1) {
      _currentIndex++;
      return _history[_currentIndex];
    }
    return null;
  }

  bool get canGoBack => _currentIndex > 0;
  bool get canGoForward => _currentIndex < _history.length - 1;

  RouteEntry? get currentRoute =>
      _currentIndex >= 0 && _currentIndex < _history.length
      ? _history[_currentIndex]
      : null;
}

