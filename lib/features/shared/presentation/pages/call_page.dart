import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:nsapp/core/services/rtc_service.dart';
import 'package:nsapp/core/core.dart';


class CallPage extends StatefulWidget {
  final String appId;
  final String token;
  final String channelName;
  final int uid;

  const CallPage({
    super.key,
    required this.appId,
    required this.token,
    required this.channelName,
    required this.uid,
  });

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  int? _remoteUid;
  bool _localUserJoined = false;
  bool _muted = false;
  bool _cameraOff = false;

  @override
  void initState() {
    super.initState();
    _initEngine();
  }

  Future<void> _initEngine() async {
    await RTCService.initialize(widget.appId);
    await RTCService.joinChannel(
      token: widget.token,
      channelId: widget.channelName,
      uid: widget.uid,
      onUserJoined: (uid) {
        setState(() {
          _remoteUid = uid;
        });
      },
      onUserOffline: (uid) {
        setState(() {
          _remoteUid = null;
        });
      },
      onLeaveChannel: () {
        if (mounted) Navigator.pop(context);
      },
    );
    setState(() {
      _localUserJoined = true;
    });
  }

  @override
  void dispose() {
    RTCService.leaveChannel();
    RTCService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(child: _remoteVideo()),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: 120,
              height: 180,
              margin: EdgeInsets.only(top: 60, left: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(50), blurRadius: 10),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _localVideo(),
              ),
            ),
          ),
          _toolbar(),
        ],
      ),
    );
  }

  Widget _localVideo() {
    if (_localUserJoined && !_cameraOff) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: RTCService.engine!,
          canvas: const VideoCanvas(uid: 0),
        ),
      );
    } else {
      return Container(
        color: Colors.grey[800],
        child: const FaIcon(FontAwesomeIcons.videoSlash, color: Colors.white, size: 32),
      );
    }
  }

  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: RTCService.engine!,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: widget.channelName),
        ),
      );
    } else {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white70),
          SizedBox(height: 20),
          Text(
            "Waiting for other party to join...",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      );
    }
  }

  Widget _toolbar() {
    return Alignment.bottomCenter.asWidget(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _circleButton(
              onPressed: () {
                setState(() {
                  _muted = !_muted;
                });
                RTCService.toggleMute(_muted);
              },
              icon: _muted ? FontAwesomeIcons.microphoneSlash : FontAwesomeIcons.microphone,
              color: _muted ? context.appColors.errorColor : Colors.white.withAlpha(50),
            ),
            const SizedBox(width: 20),
            _circleButton(
              onPressed: () {
                if (mounted) Navigator.pop(context);
              },
              icon: FontAwesomeIcons.phoneSlash,
              color: context.appColors.errorColor,
              size: 64,
            ),
            const SizedBox(width: 20),
            _circleButton(
              onPressed: () {
                setState(() {
                  _cameraOff = !_cameraOff;
                });
                RTCService.toggleCamera(_cameraOff);
              },
              icon: _cameraOff ? FontAwesomeIcons.videoSlash : FontAwesomeIcons.video,
              color: _cameraOff ? context.appColors.errorColor : Colors.white.withAlpha(50),
            ),
            const SizedBox(width: 20),
            _circleButton(
              onPressed: () {
                RTCService.switchCamera();
              },
              icon: FontAwesomeIcons.cameraRotate,
              color: Colors.white.withAlpha(50),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
    double size = 50,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: size * 0.5),
      ),
    );
  }
}

extension AlignmentExtension on Alignment {
  Widget asWidget({required Widget child}) {
    return Align(alignment: this, child: child);
  }
}

