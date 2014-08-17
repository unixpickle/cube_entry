part of cube_entry;

class _FaceColorPicker {
  final DivElement colorWell;
  final ButtonElement button;
  
  _FaceColorPicker(DivElement container) :
      colorWell = container.querySelector('div'),
      button = container.querySelector('button');
  
  void startPicking() {
    button.innerHtml = 'Cancel';
  }
  
  void stopPicking() {
    button.innerHtml = 'Set';
  }
  
  void updateColor(ScannerColor c) {
    colorWell.style.backgroundColor = 'rgb(${c.red}, ${c.green}, ${c.blue})';
  }
}

class ScannerCalibration {
  final ScannerView _view;
  final List<ScannerColor> faceColors = [];
  final List<_FaceColorPicker> _pickers = [];
  final List<StreamSubscription> _subs = [];
  
  _FaceColorPicker _picking = null;
  CanvasElement get _clickTarget => _view._overlay._canvas;
  
  ScannerCalibration(this._view) {
    DivElement root = _view._container;
    DivElement element = root.querySelector('.face-colors');
    for (DivElement child in element.querySelectorAll('.face-color')) {
      _pickers.add(new _FaceColorPicker(child));
      _subs.add(_pickers.last.button.onClick.listen(_calibratePressed));
    }
    _subs.add(_clickTarget.onClick.listen(_canvasClick));
    for (int i = 0; i < 6; ++i) {
      faceColors.add(new ScannerColor.fromIdentifier(i));
      _pickers[i].updateColor(faceColors.last);
    }
  }
  
  void destroy() {
    for (StreamSubscription s in _subs) {
      s.cancel();
    }
    if (_picking != null) {
      _picking.stopPicking();
    }
  }
  
  void _calibratePressed(MouseEvent e) {
    ButtonElement b = e.target;
    _FaceColorPicker picker = null;
    for (_FaceColorPicker p in _pickers) {
      if (p.button == b) {
        picker = p;
      }
    }
    
    if (_picking != null) {
      _picking.stopPicking();
      if (picker == _picking) {
        _picking = null;
        _updateCanvasPointer();
        return;
      }
    }
    
    _picking = picker;
    picker.startPicking();
    _updateCanvasPointer();
  }
  
  void _canvasClick(MouseEvent e) {
    if (_picking == null) return;
    Point location = e.offset - _clickTarget.offset.topLeft;
    ScannerColor color = _readColor(location);
    faceColors[_pickers.indexOf(_picking)] = color;
    _picking.updateColor(color);
    _picking.stopPicking();
    _picking = null;
    _updateCanvasPointer();
  }
  
  void _updateCanvasPointer() {
    if (_picking != null) {
      _clickTarget.style.cursor = "crosshair";
    } else {
      _clickTarget.style.cursor = "auto";
    }
  }
  
  ScannerColor _readColor(Point p) {
    CanvasElement canvas = new CanvasElement(width: 1, height: 1);
    CanvasRenderingContext2D context = canvas.getContext('2d');
    context.drawImageScaled(_view._viewport, -p.x, -p.y,
        _clickTarget.clientWidth, _clickTarget.clientHeight);
    
    List<int> values = context.getImageData(0, 0, 1, 1).data;
    return new ScannerColor(values[0], values[1], values[2]);
  }
}
