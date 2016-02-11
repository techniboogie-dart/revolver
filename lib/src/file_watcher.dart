import 'dart:io';
import 'dart:async';

import 'package:watcher/watcher.dart';

class DirectoryStreamer {
  List<String> _extList;
  bool _usePolling;

  StreamController<RevolverEvent> _streamController;

  DirectoryStreamer.fromPath(String path, {List<String> extList: const [], bool usePolling: false}) {
    this._extList = extList;
    this._usePolling = usePolling;

    Directory dir = null;

    if (path?.length > 0) {
     dir = new Directory(path);
    }
    _initStreamController(dir);
  }

  DirectoryStreamer.fromDirectory(Directory dir, {List<String> extList: const [], bool usePolling: false}) {
    this._extList = extList;
    this._usePolling = usePolling;

    _initStreamController(dir);
  }

  void _initStreamController(Directory dir) {

    if (_streamController == null) {
      _streamController = new StreamController();
    }

    if (dir == null) {
      dir = Directory.current;
    }

    if (_usePolling) {
      _streamController.addStream(
        new DirectoryWatcher(dir.path).events
        .map((WatchEvent evt) => new RevolverEvent.fromWatchEvent(evt))
      );
    }
    else {
      // Linux doesn't support the recursive directory watch. This method
      // should catch all platforms

      dir.list(recursive: true, followLinks: true)
        .where((FileSystemEntity entity) {
          FileStat stat = entity.statSync();
          return stat.type == FileSystemEntityType.DIRECTORY;
        })
        .map((FileSystemEntity entity) => entity as Directory)
        .listen((Directory dir) {
          //TODO watch for newly added dirs
          _watchDirectory(dir);
        });
    }
  }

  void _watchDirectory(dir) {
    dir.watch(events: FileSystemEvent.ALL)
      .where((FileSystemEvent evt) {
        // Only return events if stream
        // is being listened on
        return _streamController.hasListener;
      })
      .where((FileSystemEvent evt) {
        // Filter for wanted extensions
        // and watching new directories

        if (evt.isDirectory && evt.type == FileSystemEvent.CREATE) {
          print('dir');
          _watchDirectory(dir);
          return true;
        }

        for (String ext in _extList) {
          print('ext');
          if (evt.path.endsWith('.${ext}')) {
              return true;
          }
        }
        return false;
      })
      .listen((FileSystemEvent evt) => _streamController.add(
        new RevolverEvent.fromFileSystemEvent(evt)
      ));
  }

  void stop() {
    _streamController.close();
  }

  Stream<RevolverEvent> getSteam() {
    return _streamController.stream;
  }
}

Future<List<RevolverEvent>> getFileChanges(String path, {List<String> extList}) {

  return new Future<List<RevolverEvent>>(() async {
    List<RevolverEvent> events = [];
    const Duration quietTime = const Duration(milliseconds: 5000);
    Timer quietTimeCheck = null;

    DirectoryStreamer streamer = new DirectoryStreamer.fromPath(path, extList: extList);

    await for (RevolverEvent evt in streamer.getSteam()) {
      quietTimeCheck?.cancel();
      print('Future ${events}');

      events.add(evt);

      quietTimeCheck = new Timer(quietTime, () => streamer.stop());
    }
    return events;
  });
}

class RevolverEvent {
  String eventType;
  String filePath;

  RevolverEvent.fromFileSystemEvent(FileSystemEvent evt) {
    filePath = evt.path;
    eventType = getEventName(evt);
  }

  RevolverEvent.fromWatchEvent(WatchEvent evt) {
    filePath = evt.path;
    eventType = getWatchEventName(evt);
  }

  String getEventName(FileSystemEvent evt) {

    switch(evt.type) {
      case FileSystemEvent.ALL:
        return 'All';
      case FileSystemEvent.MODIFY:
        return 'Modify';
      case FileSystemEvent.CREATE:
        return 'Create';
      case FileSystemEvent.DELETE:
        return 'Delete';
      case FileSystemEvent.MOVE:
        return 'Move';
      default:
        return 'Unknown';
    }
  }

  String getWatchEventName(WatchEvent evt) {

    switch(evt.type) {
      case ChangeType.ADD:
        return 'Create';
      case ChangeType.MODIFY:
        return 'Modify';
      case ChangeType.REMOVE:
        return 'Delete';
      default:
        return 'Unknown';
    }
  }
}
