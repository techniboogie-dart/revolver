Automatically reloads your command line application when changes to files are detected. Monitoring occurs on files within the current path, recursively.  

_Check the documentation for extra functionality using the API._

Revolver was influenced by [Nodemon](https://github.com/remy/nodemon).

### Installation ###
    pub global activate revolver

### Usage ###
###### revolver _[options...]_ application _[application arguments...]_ ######

    $ revolver --help
    -e, --ext                 Watch only the specified extensions.
    -w, --working-dir         Overrides the current working directory,.
                              (defaults to "/files/projects/dart/revolver")

    -p, --use-polling         Using file polling, rather than file system events, to detect file changes.
    -h, --help                Displays this help information.
    -g, --[no-]git            Ignores git files and respects the contents of .gitignore.
                              (defaults to on)

    -d, --[no-]ignore-dart    Ignore dart project files.
                              (defaults to on)


### Examples ###

    $ revolver --ext="dart,yaml,conf" application.dart
    Start.     application.dart
    Modified.  application.dart
    Reload.    application.dart


    $ revolver --git bin/server.dart -p 8080
    Start.     bin/server.dart
    New File.  bin/test1
    Reload.    bin/server.dart
    Deleted.   bin/test1
    Reload.    bin/server.dart
