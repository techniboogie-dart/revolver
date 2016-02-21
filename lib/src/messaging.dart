import 'package:ansicolor/ansicolor.dart';

import 'package:revolver/revolver.dart';

const String _modifyLabel = 'Modified';
const String _createLabel = 'New File';
const String _deleteLabel = 'Deleted';
const String _moveLabel = 'Moved';
const String _multiLabel = '${_createLabel}/${_modifyLabel}/${_deleteLabel}';
const String _unknownLabel = 'Unknown';

void printMessage(String message, {String label}) {

  if (label != null) {
    message = '${_getPen(Color.blue)(label + ".")}  ${message}';
  }
  print(message);
}

void printEvent(RevolverEvent event) {
  String coloredLabel = null;

  switch(event.type) {
    case RevolverEventType.create:
      coloredLabel = _getPen(Color.green)(_createLabel + '.');
      break;
    case RevolverEventType.modify:
      coloredLabel = _getPen(Color.yellow)(_modifyLabel + '.');
      break;
    case RevolverEventType.move:
      coloredLabel = _getPen(Color.orange)(_moveLabel + '.');
      break;
    case RevolverEventType.delete:
      coloredLabel = _getPen(Color.red)(_deleteLabel + '.');
      break;
    case RevolverEventType.multi:
      coloredLabel = _getPen(Color.purple)(_multiLabel + '.');
      break;
    default:
      coloredLabel = _getPen(Color.grey)(_unknownLabel + '.');
      break;
  }

  print('${coloredLabel}  ${event.filePath}');
}

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

String formatExtensionList(List<String> extensions) {
  return extensions
  .map((String extension) => '*.' + extension)
  .join(' ');
}
