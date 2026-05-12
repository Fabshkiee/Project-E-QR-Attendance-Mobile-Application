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
  static Future playOnCoachSuccess(String username, String status) async {
    tts.start('Welcome, Coach $username!');
  }

  static Future playOnMemberSuccess(String username, String status) async {
    tts.start('Welcome, $username! Your status is $status.');
    
  }

  
}

