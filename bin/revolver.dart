import 'package:revolver/revolver.dart' as revolver;

void main(List<String> args) {
  //baseDir fileTypes bin args
  // String entry = args[0];

 // add polling option
  revolver.start(new revolver.RevolverConfiguration('../test/main.dart', binArgs: ['hello'], baseDir: '.', extList: ['dart', 'txt'], reloadDelayMs: 5000));

  print('here we go!');

}
