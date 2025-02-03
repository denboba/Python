import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoCallService {
  static const String appId = "c409693ea757494ab7dd619a8264010f"; // Replace with your Agora App ID
  
  RtcEngine? engine;
  int? localUid;
  bool isJoined = false;

  Future<void> initializeAgora() async {
    // Request permissions
    await [Permission.microphone, Permission.camera].request();

    // Create RTC engine instance
    engine = createAgoraRtcEngine();
    await engine!.initialize(const RtcEngineContext(appId: appId));

    // Enable video
    await engine!.enableVideo();
    await engine!.enableAudio();

    // Set up event handlers
    engine!.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        isJoined = true;
        localUid = connection.localUid;
      },
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        // Handle remote user joined
      },
      onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
        // Handle remote user left
      },
    ));
  }

  Future<void> joinChannel(String channelName, String token) async {
    await engine?.joinChannel(
      token: token,
      channelId: channelName,
      uid: 0,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );
  }

  Future<void> leaveChannel() async {
    await engine?.leaveChannel();
    isJoined = false;
  }

  Future<void> toggleMicrophone(bool muted) async {
    await engine?.muteLocalAudioStream(muted);
  }

  Future<void> toggleCamera(bool enabled) async {
    await engine?.muteLocalVideoStream(!enabled);
  }

  Future<void> switchCamera() async {
    await engine?.switchCamera();
  }

  void dispose() {
    engine?.release();
  }
}
