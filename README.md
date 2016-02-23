Automatically reloads your command line application when changes to files are detected. Monitoring occurs on files within the current path, recursively.  

_Check the documentation for extra functionality using the API._

Revolver was influenced by [Nodemon](https://github.com/remy/nodemon).

### Usage
    revolver [OPTIONS] APPLICATION.dart [PARAMS ...]


###### Options
__--ext, -e__

Watch only the specified extensions: `--ext="dart,yaml,conf"`

__--use-polling, -p__  

Using file polling, rather than file system events, to detect file changes.
