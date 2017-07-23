import 'dart:isolate';
import 'dart:io';
import 'dart:async';

import 'package:watcher/watcher.dart';

import 'package:revolver/src/messaging.dart';
import 'package:revolver/src/reload_throttle.dart' as throttle;

/// Runs and monitors the dart application, using the the supplied [RevolverConfiguration]
///
/// Creates an isolate that is managed by the [reload_throttle].[startTimer]
void start(RevolverConfiguration config) {
  printMessage(config.bin, label: 'Start');

  if (config.extList != null) {
    printMessage(formatExtensionList(config.extList), label: 'Watch');
  }

  ReceivePort receiver = new ReceivePort();
  Stream receiverStream = receiver.asBroadcastStream();

  Future<Isolate> _createIsolate() {

    return Isolate.spawnUri(
      new Uri.file(config.bin, windows: Platform.isWindows),
      config.binArgs,
      null,
      automaticPackageResolution: true
    )
    .then((Isolate i) {
      StreamSubscription streamSub = null;

      streamSub = receiverStream.listen((RevolverAction action) {
        printMessage(config.bin, label: 'Reload');

        i.kill();
        streamSub.cancel();

        _createIsolate();
      });
    });
  }

  // Create initial isolate
  _createIsolate();
  throttle.startTimer(
    receiver.sendPort,
    baseDir: config.baseDir,
    extList: config.extList,
    reloadDelayMs: config.reloadDelayMs,
    usePolling: config.usePolling
  );
}

/// The configuration for the initial loading of revolver. See [start]
class RevolverConfiguration {
  String baseDir;
  List<String> extList;
  String bin;
  List<String> binArgs;
  int reloadDelayMs;
  bool usePolling;

  RevolverConfiguration(this.bin, {
    this.binArgs,
    this.baseDir: '.',
    this.extList,
    this.reloadDelayMs: 500,
    this.usePolling: false
  });
}

enum RevolverAction {
  reload
}

enum RevolverEventType {
  create,
  modify,
  delete,
  move,
  multi
}

/// The exception that is thrown when a file event occurs.
class RevolverEvent {
  RevolverEventType type;
  String filePath;

  /// Creates a [RevolverEvent] from a [FileSystemEvent]
  RevolverEvent.fromFileSystemEvent(FileSystemEvent evt) {
    filePath = evt.path;
    type = _getEventType(evt);
  }

  /// Creates a [RevolverEvent] from a [WatchEvent]
  RevolverEvent.fromWatchEvent(WatchEvent evt) {
    filePath = evt.path;
    type = _getEventTypeFromWatchEvent(evt);
  }

  RevolverEventType _getEventType(FileSystemEvent evt) {

    switch(evt.type) {
      case FileSystemEvent.ALL:
        return RevolverEventType.multi;
      case FileSystemEvent.MODIFY:
        return RevolverEventType.modify;
      case FileSystemEvent.CREATE:
        return RevolverEventType.create;
      case FileSystemEvent.DELETE:
        return RevolverEventType.delete;
      case FileSystemEvent.MOVE:
        return RevolverEventType.move;
      default:
        return null;
    }
  }

  RevolverEventType _getEventTypeFromWatchEvent(WatchEvent evt) {

    switch(evt.type) {
      case ChangeType.ADD:
        return RevolverEventType.create;
      case ChangeType.MODIFY:
        return RevolverEventType.modify;
      case ChangeType.REMOVE:
        return RevolverEventType.delete;
      default:
        return null;
    }
  }
}
