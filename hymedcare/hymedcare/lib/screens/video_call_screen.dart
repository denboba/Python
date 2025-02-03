import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../services/video_call_service.dart';

class VideoCallScreen extends StatefulWidget {
  final String channelName;
  final String token;
  final String remoteUserName;

  const VideoCallScreen({
    super.key,
    required this.channelName,
    required this.token,
    required this.remoteUserName,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final _videoCallService = VideoCallService();
  bool _localAudioMuted = false;
  bool _localVideoMuted = false;

  @override
  void initState() {
    super.initState();
    _initializeAndJoinCall();
  }

  Future<void> _initializeAndJoinCall() async {
    await _videoCallService.initializeAgora();
    await _videoCallService.joinChannel(widget.channelName, widget.token);
  }

  @override
  void dispose() {
    _videoCallService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Remote video
            Center(
              child: _remoteVideo(),
            ),
            // Local video
            Align(
              alignment: Alignment.topRight,
              child: Container(
                width: 120,
                height: 160,
                margin: const EdgeInsets.all(16),
                child: _localVideo(),
              ),
            ),
            // Controls
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RawMaterialButton(
                      onPressed: _onToggleMute,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12),
                      fillColor: _localAudioMuted ? Colors.red : Colors.white,
                      child: Icon(
                        _localAudioMuted ? Icons.mic_off : Icons.mic,
                        color: _localAudioMuted ? Colors.white : Colors.blue,
                        size: 20,
                      ),
                    ),
                    RawMaterialButton(
                      onPressed: () => _onCallEnd(context),
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(15),
                      fillColor: Colors.red,
                      child: const Icon(
                        Icons.call_end,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                    RawMaterialButton(
                      onPressed: _onSwitchCamera,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12),
                      fillColor: Colors.white,
                      child: const Icon(
                        Icons.switch_camera,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                    RawMaterialButton(
                      onPressed: _onToggleVideo,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12),
                      fillColor: _localVideoMuted ? Colors.red : Colors.white,
                      child: Icon(
                        _localVideoMuted ? Icons.videocam_off : Icons.videocam,
                        color: _localVideoMuted ? Colors.white : Colors.blue,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _localVideo() {
    if (_videoCallService.engine == null) return const SizedBox.shrink();
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _videoCallService.engine!,
        canvas: const VideoCanvas(uid: 0),
      ),
    );
  }

  Widget _remoteVideo() {
    if (_videoCallService.engine == null) return const SizedBox.shrink();
    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: _videoCallService.engine!,
        canvas: const VideoCanvas(uid: 1),
        connection: RtcConnection(channelId: widget.channelName),
      ),
    );
  }

  void _onToggleMute() {
    setState(() {
      _localAudioMuted = !_localAudioMuted;
    });
    _videoCallService.toggleMicrophone(_localAudioMuted);
  }

  void _onToggleVideo() {
    setState(() {
      _localVideoMuted = !_localVideoMuted;
    });
    _videoCallService.toggleCamera(!_localVideoMuted);
  }

  void _onSwitchCamera() {
    _videoCallService.switchCamera();
  }

  void _onCallEnd(BuildContext context) {
    _videoCallService.leaveChannel();
    Navigator.pop(context);
  }
}
