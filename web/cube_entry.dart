library cube_entry;

import 'dart:html';
import 'dart:math';
import 'dart:async';

part 'scanner_view.dart';
part 'scanner_overlay.dart';
part 'scanner_analyzer.dart';
part 'scanner_color.dart';
part 'scanner_calibration.dart';

void main() {
  DivElement root = querySelector('.video-container');
  ScannerView view = new ScannerView(root);
  view.start().then((_) {
    ScannerCalibration calibration = new ScannerCalibration(view);
    ScannerAnalyzer analyzer = new ScannerAnalyzer(calibration, view);
    
    querySelector('#scan-photo').onClick.listen((_) {
      var canvas = analyzer.generateVisualRepresentation();
      window.location.assign(canvas.toDataUrl());
      return;
    });
  });
}
