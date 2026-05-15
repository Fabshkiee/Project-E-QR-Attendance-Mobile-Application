import 'package:stts/stts.dart';

final tts = Tts();

// Get state changes
final sub = tts.onStateChanged.listen(
  (ttsState) {
    /* TtsState.start/stop/pause */
  },
  onError: (err) {
    /* Retrieve listener errors from here */
  },
);

class TtsService {
  static Future playOnSuccess(String username, String status, String role) async {
    if (role.contains('Staff')) {
      tts.start('Welcome, $username!');
    } else {
      tts.start('Welcome, $username! Your status is $status.');
    }
  }
  
}

