import 'package:ansicolor/ansicolor.dart';

import 'package:revolver/revolver.dart';
import 'package:revolver/src/file_util.dart';

const String _modifyLabel = 'Modified';
const String _createLabel = 'New File';
const String _deleteLabel = 'Deleted';
const String _moveLabel = 'Moved';
const String _errorLabel = 'Error';
const String _multiLabel = '${_createLabel}/${_modifyLabel}/${_deleteLabel}';
const String _unknownLabel = 'Unknown';

/// Prints message, prefixed with an optional BLUE label.
void printMessage(String message, {String label}) {

  if (label != null) {
    message = _formatMessage(Color.blue, '${label}.', message);
  }
  print(message);
}

/// Prints the details of a [RevolverEvent], using the appropriate color.
void printEvent(RevolverEvent event) {
  String message;

  switch(event.type) {
    case RevolverEventType.create:
      message = _formatMessage(Color.green, '${_createLabel}.', event.filePath);
      break;
    case RevolverEventType.modify:
      message = _formatMessage(Color.yellow, '${_modifyLabel}.', event.filePath);
      break;
    case RevolverEventType.move:
      message = _formatMessage(Color.orange, '${_moveLabel}.', event.filePath);
      break;
    case RevolverEventType.delete:
      message = _formatMessage(Color.red, '${_deleteLabel}.', event.filePath);
      break;
    case RevolverEventType.multi:
      message = _formatMessage(Color.purple, '${_multiLabel}.', event.filePath);
      break;
    default:
      message = _formatMessage(Color.grey, '${_unknownLabel}.', event.filePath);
      break;
  }
  print(message);
}

String _formatMessage(Color labelColor, String label, String message) {
  label = label.padRight(12);
  return '${_getPen(labelColor)(label)} ${convertToRelativePath(message)}';
}

/// Prints an error message in RED.
void printError(String message) {
  print(_getPen(Color.bigRed)(message));
}

enum Color {
  green,
  yellow,
  red,
  blue,
  bigRed,
  purple,
  orange,
  grey
}

AnsiPen _getPen(Color color) {
  AnsiPen pen = new AnsiPen();

  switch (color) {
    case Color.green:
      return pen..rgb(r: 0.5, g: 0.9, b: 0.5);
    case Color.yellow:
      return pen..rgb(r: 1.0, g: 1.0, b: 0.5);
    case Color.red:
      return pen..rgb(r: 1.0, g: 0.4, b: 0.4);
    case Color.blue:
      return pen..rgb(r: 0.0, g: 0.5, b: 1.0);
    case Color.bigRed:
      return pen..rgb(r: 1.0, g: 0.2, b: 0.2);
    case Color.orange:
      return pen..rgb(r: 1.0, g: 0.6, b: 0.0);
    case Color.purple:
      return pen..rgb(r: 0.9, g: 0.3, b: 1.0);
    case Color.grey:
      return pen..rgb(r: 0.6, g: 0.6, b: 0.6);
    default:
      return null;
  }
}

/// Formats a list of file extensions for display.
String formatExtensionList(List<String> extensions) {
  return extensions
  ?.map((String extension) => '*.' + extension)
  ?.join(' ');
}
