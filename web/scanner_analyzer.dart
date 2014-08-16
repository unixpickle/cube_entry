part of cube_entry;

class ScannerAnalyzer {
  final ScannerView _view;
  final CanvasElement _canvas;
  CanvasRenderingContext2D _context;
  
  ScannerAnalyzer(this._view) : _canvas = new CanvasElement() {
    _canvas.width = 1024;
    _canvas.height = 1024;
    _context = _canvas.getContext('2d');
  }
  
  int colorOfSquare(int squareIdx) {
    List<int> colors = pixelColorsOfSquare(squareIdx);
    List<int> counts = [0, 0, 0, 0, 0, 0];
    for (int c in colors) {
      ++counts[c];
    }
    int max = 0;
    int maxColor = 0;
    for (int i = 0; i < 6; ++i) {
      if (counts[i] >= max) {
        maxColor = i;
        max = counts[i];
      }
    }
    return maxColor;
  }
  
  List<int> pixelColorsOfSquare(int squareIdx) {
    _readSquare(squareIdx);
    
    ImageData data = _context.getImageData(0, 0, _canvas.width, _canvas.height);
    List<int> values = data.data;
    
    List<ScannerColor> defaults = [];
    for (int i = 0; i < 6; ++i) {
      defaults.add(new ScannerColor.fromIdentifier(i));
    }
    
    List<int> result = [];
    for (int y = 0; y < data.height; ++y) {
      for (int x = 0; x < data.width; ++x) {
        int idx = 4 * (x + (y * data.width));
        ScannerColor color = new ScannerColor(values[idx], values[idx + 1],
            values[idx + 2]);
        int colorIdx = -1;
        int diff = 0x300;
        for (int i = 0; i < 6; ++i) {
          if (defaults[i].difference(color) <= diff) {
            colorIdx = i;
            diff = defaults[i].difference(color);
          }
        }
        result.add(colorIdx);
      }
    }
    return result;
  }
  
  CanvasElement generateVisualRepresentation({int size: 512}) {
    CanvasElement el = new CanvasElement(width: size, height: size);
    CanvasRenderingContext2D context = el.getContext('2d');
    
    ScannerOverlay overlay = _view._overlay;
    num scale = size / overlay.gridSize;
    context.clearRect(0, 0, size, size);
    context.drawImageScaled(_view._viewport, -overlay.gridX * scale,
        -overlay.gridY * scale, _view._viewport.videoWidth * scale,
        _view._viewport.videoHeight * scale);
    
    ImageData data = context.getImageData(0, 0, _canvas.width, _canvas.height);
    List<int> values = data.data;
    
    for (int y = 0; y < data.height; ++y) {
      for (int x = 0; x < data.width; ++x) {
        int idx = 4 * (x + (y * data.width));
        ScannerColor color = new ScannerColor(values[idx], values[idx + 1],
            values[idx + 2]);
        int colorIdx = color.faceColor();
        ScannerColor defaultColor = new ScannerColor.fromIdentifier(colorIdx);
        values[idx] = defaultColor.red;
        values[idx + 1] = defaultColor.green;
        values[idx + 2] = defaultColor.blue;
      }
    }
    context.putImageData(data, 0, 0);
    
    return el;
  }
  
  void _readSquare(int squareIdx) {
    ScannerOverlay overlay = _view._overlay;
    int x = (overlay.gridX + (squareIdx % 3) * overlay.gridSize / 3).round();
    int y = (overlay.gridY + (squareIdx ~/ 3) * overlay.gridSize / 3).round();
    int size = overlay.gridSize ~/ 3;
    _readRegion(x, y, size);
  }
  
  void _readRegion(int x, int y, int size) {
    num scale = _canvas.width / size;
    _context.clearRect(0, 0, _canvas.width, _canvas.height);
    _context.drawImageScaled(_view._viewport, -x * scale, -y * scale,
        _view._viewport.videoWidth * scale,
        _view._viewport.videoHeight * scale);
  }
  
}
