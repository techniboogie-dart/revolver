import 'dart:isolate';
import 'dart:io';
import 'dart:async';

import 'package:watcher/watcher.dart';

import 'package:revolver/src/messaging.dart';
import 'package:revolver/src/reload_throttle.dart' as throttle;

void start(RevolverConfiguration config) {
  printMessage(formatExtensionList(config.extList), label: 'Watch');

  ReceivePort receiver = new ReceivePort();
  Stream receiverStream = receiver.asBroadcastStream();

  Future<Isolate> _createIsolate() {

    return Isolate.spawnUri(
      new Uri.file(config.bin, windows: Platform.isWindows),
      config.binArgs,
      null)
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
  throttle.startTimer(receiver.sendPort, baseDir: config.baseDir, extList: config.extList, reloadDelayMs: config.reloadDelayMs);
}

class RevolverConfiguration {
  String baseDir;
  List<String> extList;
  String bin;
  List<String> binArgs;
  int reloadDelayMs;

  RevolverConfiguration(this.bin, {this.binArgs, this.baseDir, this.extList, this.reloadDelayMs});
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

class RevolverEvent {
  RevolverEventType type;
  String filePath;

  RevolverEvent.fromFileSystemEvent(FileSystemEvent evt) {
    filePath = evt.path;
    type = _getEventType(evt);
  }

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
