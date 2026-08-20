import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'dart:async';
import 'dart:developer';
import 'dart:convert';

class PusherService {
  late PusherChannelsFlutter pusher;
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onMessageReceived =>
      _messageController.stream;

  // TODO: Update these with the actual Laravel backend Pusher/Reverb credentials
  final String _apiKey = "REPLACE_WITH_PUSHER_KEY";
  final String _cluster = "REPLACE_WITH_PUSHER_CLUSTER";
  // If using Laravel Reverb/WebSockets (local server), you may need custom host/wsPort settings

  Future<void> init() async {
    try {
      pusher = PusherChannelsFlutter.getInstance();
      await pusher.init(
        apiKey: _apiKey,
        cluster: _cluster,
        onEvent: _onEvent,
        onSubscriptionSucceeded: _onSubscriptionSucceeded,
        onSubscriptionError: _onSubscriptionError,
      );
      await pusher.connect();
      log("Pusher connected successfully");
    } catch (e) {
      log("Pusher init error: $e");
    }
  }

  void _onEvent(PusherEvent event) {
    log("Pusher event received: ${event.eventName}");
    if (event.data != null && event.data.toString().isNotEmpty) {
      try {
        final Map<String, dynamic> data = jsonDecode(event.data.toString());
        _messageController.add({
          'event': event.eventName,
          'channel': event.channelName,
          'data': data,
        });
      } catch (e) {
        log("Error decoding pusher event data: $e");
      }
    }
  }

  void _onSubscriptionSucceeded(String channelName, dynamic data) {
    log("Subscribed to $channelName");
  }

  void _onSubscriptionError(String message, dynamic e) {
    log("Subscription error: $message");
  }

  Future<void> subscribeToChannel(String channelName) async {
    try {
      await pusher.subscribe(channelName: channelName);
    } catch (e) {
      log("Error subscribing to channel: $e");
    }
  }

  Future<void> unsubscribeFromChannel(String channelName) async {
    try {
      await pusher.unsubscribe(channelName: channelName);
    } catch (e) {
      log("Error unsubscribing from channel: $e");
    }
  }
}
