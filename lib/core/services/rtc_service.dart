import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class RTCService {
  static RtcEngine? _engine;
  static bool _isInitialized = false;

  static Future<void> initialize(String appId) async {
    if (_isInitialized) return;

    // Request permissions
    await [Permission.microphone, Permission.camera].request();

    _engine = createAgoraRtcEngine();
    await _engine!.initialize(
      RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    await _engine!.enableVideo();
    await _engine!.startPreview();

    _isInitialized = true;
  }

  static Future<void> joinChannel({
    required String token,
    required String channelId,
    required int uid,
    required Function(int remoteUid) onUserJoined,
    required Function(int remoteUid) onUserOffline,
    required Function() onLeaveChannel,
  }) async {
    if (_engine == null) return;

    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("Local user ${connection.localUid} joined");
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("Remote user $remoteUid joined");
          onUserJoined(remoteUid);
        },
        onUserOffline:
            (
              RtcConnection connection,
              int remoteUid,
              UserOfflineReasonType reason,
            ) {
              debugPrint("Remote user $remoteUid left");
              onUserOffline(remoteUid);
            },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          debugPrint("Local user left channel");
          onLeaveChannel();
        },
      ),
    );

    await _engine!.joinChannel(
      token: token,
      channelId: channelId,
      uid: uid,
      options: const ChannelMediaOptions(),
    );
  }

  static Future<void> leaveChannel() async {
    if (_engine == null) return;
    await _engine!.leaveChannel();
  }

  static Future<void> dispose() async {
    if (_engine == null) return;
    await _engine!.release();
    _engine = null;
    _isInitialized = false;
  }

  static RtcEngine? get engine => _engine;

  static Future<void> toggleMute(bool muted) async {
    await _engine?.muteLocalAudioStream(muted);
  }

  static Future<void> toggleCamera(bool off) async {
    await _engine?.muteLocalVideoStream(off);
  }

  static Future<void> switchCamera() async {
    await _engine?.switchCamera();
  }
}
