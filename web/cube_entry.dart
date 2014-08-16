library cube_entry;

import 'dart:html';
import 'dart:math';
import 'dart:async';

part 'scanner_view.dart';
part 'scanner_overlay.dart';
part 'scanner_analyzer.dart';
part 'scanner_color.dart';

void main() {
  ScannerView view = new ScannerView(querySelector('.video-container'));
  ScannerAnalyzer analyzer = new ScannerAnalyzer(view);
  view.start().then((_) {
    querySelector('#scan-photo').onClick.listen((_) {
      var canvas = analyzer.generateVisualRepresentation();
      window.location.assign(canvas.toDataUrl());
      return;
      /*
      for (int i = 0; i < 9; ++i) {
        String cName = ScannerColor.COLOR_NAMES[analyzer.colorOfSquare(i)];
        print('color $i is $cName');
      }
      */
    });
  });
}
