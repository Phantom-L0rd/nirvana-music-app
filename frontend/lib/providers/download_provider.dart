import 'package:flutter/foundation.dart';
import 'package:nirvana_desktop/models/models.dart';
import 'package:nirvana_desktop/services/download_service.dart';

class DownloadNotifier extends ChangeNotifier {
  final DownloadService _service;
  double _progress = 0.0;
  String _stage = "";
  bool _isDownloading = false;
  String? _error;

  DownloadNotifier(this._service);

  double get progress => _progress;
  String get stage => _stage;
  bool get isDownloading => _isDownloading;
  String? get error => _error;

  void startDownload(OnlineTrack song) {
    _isDownloading = true;
    _progress = 0.0;
    _stage = "Starting...";
    _error = null;
    notifyListeners();

    _service.startDownload(
      song: song,
      onProgress: (progress, stage) {
        _progress = progress;
        _stage = stage;
        notifyListeners();
      },
      onDone: () {
        _isDownloading = false;
        _stage = "Done";
        _progress = 100.0;
        notifyListeners();
      },
      onError: (err) {
        _isDownloading = false;
        _error = err.toString();
        notifyListeners();
      },
    );
  }

  void cancelDownload() {
    _service.close();
    _isDownloading = false;
    _stage = "Cancelled";
    notifyListeners();
  }
}
