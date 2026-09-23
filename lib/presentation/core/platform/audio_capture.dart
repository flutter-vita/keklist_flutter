import 'package:record/record.dart';

/// Whether this build can capture audio, asked once and remembered.
///
/// `record: ^7.0.0` ships implementations for Android, iOS, macOS, Windows,
/// Linux and web. There is no Vita one, and the port has no microphone support
/// to write one against, so the plugin is simply not registered and the first
/// method call comes back unimplemented.
///
/// Without this the mic button in the comment bar looks live: tapping it opens
/// the recorder sheet, which then fails inside `record` and leaves the user
/// with a sheet that cannot record. Hiding the button says the same thing
/// honestly and costs one call at startup.
///
/// The default is "no". An unregistered channel raises `MissingPluginException`
/// and is caught below, but a platform channel with nothing on the other end
/// can also never reply, in which case the await here never returns. Starting
/// from `false` and only ever flipping to `true` on a real answer means a hang
/// hides the button rather than hanging the screen that asked.
abstract final class AudioCapture {
  static bool _supported = false;
  static bool _probed = false;

  /// Cached answer. False until [probe] has come back positive.
  static bool get isSupported => _supported;

  static Future<bool> probe() async {
    if (_probed) {
      return _supported;
    }
    _probed = true;
    try {
      final AudioRecorder recorder = AudioRecorder();
      await recorder.hasPermission();
      await recorder.dispose();
      _supported = true;
    } catch (_) {
      _supported = false;
    }
    return _supported;
  }
}
