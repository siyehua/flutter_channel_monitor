import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'channel_monitor.dart';

class CustomFlutterBinding extends WidgetsFlutterBinding {
  @protected
  BinaryMessenger createBinaryMessenger() {
    return DefaultBinaryMessengerWithMonitor.instance;
  }
}

/// The class copy form [BinaryMessenger], but it has monitor channel profiler.
///
/// The default implementation of [BinaryMessenger].
///
/// This messenger sends messages from the app-side to the platform-side and
/// dispatches incoming messages from the platform-side to the appropriate
/// handler.
///
class DefaultBinaryMessengerWithMonitor extends BinaryMessenger {
  static final DefaultBinaryMessengerWithMonitor instance =
      const DefaultBinaryMessengerWithMonitor._();

  const DefaultBinaryMessengerWithMonitor._();

  // Handlers for incoming messages from platform plugins.
  // This is static so that this class can have a const constructor.
  static final Map<String, MessageHandler> _handlers =
      <String, MessageHandler>{};

  // Mock handlers that intercept and respond to outgoing messages.
  // This is static so that this class can have a const constructor.
  static final Map<String, MessageHandler> _mockHandlers =
      <String, MessageHandler>{};

  // channel monitor manger
  static final ChannelMonitorManager _channelMonitorManager =
      ChannelMonitorManager.instance;

  Future<ByteData?> _sendPlatformMessage(String channel, ByteData? message) {
    final Completer<ByteData?> completer = Completer<ByteData?>();
    // ui.PlatformDispatcher.instance is accessed directly instead of using
    // ServicesBinding.instance.platformDispatcher because this method might be
    // invoked before any binding is initialized. This issue was reported in
    // #27541. It is not ideal to statically access
    // ui.PlatformDispatcher.instance because the PlatformDispatcher may be
    // dependency injected elsewhere with a different instance. However, static
    // access at this location seems to be the least bad option.

    var monitor = _channelMonitorManager.start(channel, message);
    ui.PlatformDispatcher.instance.sendPlatformMessage(channel, message,
        (ByteData? reply) {
      try {
        if (monitor != null) {
          _channelMonitorManager.end(monitor);
        }
        completer.complete(reply);
      } catch (exception, stack) {
        if (monitor != null) {
          _channelMonitorManager.end(monitor, exception, stack);
        }
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'services library',
          context:
              ErrorDescription('during a platform message response callback'),
        ));
      }
    });
    return completer.future;
  }

  @override
  Future<void> handlePlatformMessage(
    String channel,
    ByteData? data,
    ui.PlatformMessageResponseCallback? callback,
  ) async {
    ByteData? response;
    try {
      final MessageHandler? handler = _handlers[channel];
      if (handler != null) {
        response = await handler(data);
      } else {
        ui.channelBuffers.push(channel, data, callback!);
        callback = null;
      }
    } catch (exception, stack) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: exception,
        stack: stack,
        library: 'services library',
        context: ErrorDescription('during a platform message callback'),
      ));
    } finally {
      if (callback != null) {
        callback(response);
      }
    }
  }

  @override
  Future<ByteData?>? send(String channel, ByteData? message) {
    final MessageHandler? handler = _mockHandlers[channel];
    if (handler != null) return handler(message);
    return _sendPlatformMessage(channel, message);
  }

  @override
  void setMessageHandler(String channel, MessageHandler? handler) {
    if (handler == null) {
      _handlers.remove(channel);
    } else {
      _handlers[channel] = handler;
      ui.channelBuffers.drain(channel,
          (ByteData? data, ui.PlatformMessageResponseCallback callback) async {
        await handlePlatformMessage(channel, data, callback);
      });
    }
  }

  @override
  bool checkMessageHandler(String channel, MessageHandler? handler) =>
      _handlers[channel] == handler;

  @override
  void setMockMessageHandler(String channel, MessageHandler? handler) {
    if (handler == null)
      _mockHandlers.remove(channel);
    else
      _mockHandlers[channel] = handler;
  }

  @override
  bool checkMockMessageHandler(String channel, MessageHandler? handler) =>
      _mockHandlers[channel] == handler;
}
