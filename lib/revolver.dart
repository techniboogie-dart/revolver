import 'dart:isolate';
import 'dart:io';
import 'dart:async';

import 'package:watcher/watcher.dart';

import 'package:revolver/src/messaging.dart';
import 'package:revolver/src/reload_throttle.dart' as throttle;

/// Runs and monitors the dart application, using the the supplied [RevolverConfiguration]
///
/// Creates an isolate that is managed by the [reload_throttle].[startTimer]
void start() {
  String bin = RevolverConfiguration.bin;
  List<String> extList = RevolverConfiguration.extList;
  List<String> binArgs = RevolverConfiguration.binArgs;

  printMessage(bin, label: 'Start');

  if (extList != null) {
    printMessage(formatExtensionList(extList), label: 'Watch');
  }

  ReceivePort receiver = new ReceivePort();
  ReceivePort errorReceiver = new ReceivePort();

  Stream receiverStream = receiver.asBroadcastStream();
  Stream errorReceiverStream = errorReceiver.asBroadcastStream();

  Isolate process = null;

  Future<Isolate> createIsolate() async {
    // Kill previous process.
    process?.kill(priority: Isolate.IMMEDIATE);

    process = await Isolate.spawnUri(
      new Uri.file(bin, windows: Platform.isWindows),
      binArgs,
      null,
      automaticPackageResolution: true,
      errorsAreFatal: true,
      onError: errorReceiver.sendPort
    );

    return process;
  }

  receiverStream.listen((RevolverAction action) {
    printMessage(bin, label: 'Reload');
    createIsolate();
  });

  errorReceiverStream.listen((errors) {
    printError('Process failed. Will try again on next file change.');
    printMessage(errors);
  });

  // Create initial isolate
  createIsolate();
  throttle.startTimer(receiver.sendPort);
}

/// The configuration for the initial loading of revolver. See [start]
class RevolverConfiguration {
  static String bin;
  static List<String> binArgs;
  static String baseDir;
  static List<String> extList;
  static int reloadDelayMs;
  static bool usePolling;
  static bool isGitProject;
  static bool doIgnoreDart;

  static initialize(bin, {
    binArgs,
    baseDir: '.',
    extList,
    reloadDelayMs: 500,
    usePolling: false,
    isGitProject: false,
    doIgnoreDart: true
  }) {
    RevolverConfiguration.bin = bin;
    RevolverConfiguration.binArgs = binArgs;
    RevolverConfiguration.baseDir = baseDir;
    RevolverConfiguration.extList = extList;
    RevolverConfiguration.reloadDelayMs = reloadDelayMs;
    RevolverConfiguration.usePolling = usePolling;
    RevolverConfiguration.isGitProject = isGitProject;
    RevolverConfiguration.doIgnoreDart = doIgnoreDart;
  }
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
    this.filePath = evt.path;
    this.type = _getEventType(evt);
  }

  /// Creates a [RevolverEvent] from a [WatchEvent]
  RevolverEvent.fromWatchEvent(WatchEvent evt) {
    this.filePath = evt.path;
    this.type = _getEventTypeFromWatchEvent(evt);
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
