import 'dart:convert';

import 'package:nirvana_desktop/models/models.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

class DownloadService {
  WebSocketChannel? _channel;
  static const String baseUrl = 'http://localhost:8000';

  DownloadService();

  void startDownload({
    required OnlineTrack song,
    required void Function(double progress, String stage) onProgress,
    required void Function() onDone,
    required void Function(Object error) onError,
  }) {
    _channel = WebSocketChannel.connect(Uri.parse('$baseUrl/ws/download'));

    _channel!.stream.listen(
      (message) {
        try {
          final data = jsonDecode(message);
          final progress = (data['progress'] as num).toDouble();
          final stage = data['stage'] as String;

          onProgress(progress, stage);

          if (stage == "done" || progress >= 100.0) {
            onDone();
            close();
          }
        } catch (e) {
          onError(e);
        }
      },
      onError: onError,
      onDone: onDone,
    );

    _channel!.sink.add(jsonEncode({'song':song}));
  }

  void close() {
    _channel?.sink.close(status.normalClosure);
    _channel = null;
  }
}
