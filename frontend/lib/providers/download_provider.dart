import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;
import 'package:nirvana_desktop/models/models.dart';

class DownloadService with ChangeNotifier {
  double _progress = 0;
  double get progress => _progress;

  String? _jobId;
  bool _downloading = false;
  bool get isDownloading => _downloading;

  String _id = '';
  String get id => _id;

  Future<void> startDownload(OnlineTrack song) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/start-download'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(song.toJson()),
    );

    final data = jsonDecode(response.body);
    _id = song.id;
    _jobId = data['job_id'];
    _progress = 0;
    _downloading = true;
    notifyListeners();

    // Start polling for progress
    _pollProgress();
  }

  void _pollProgress() {
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_jobId == null) return;

      final res = await http.get(
        Uri.parse('http://127.0.0.1:8000/progress/$_jobId'),
      );

      final data = jsonDecode(res.body);
      _progress = (data['progress'] ?? 0).toDouble();
      notifyListeners();

      if (_progress >= 100) {
        _downloading = false;
        notifyListeners();
        timer.cancel();
      }
    });
  }
}
