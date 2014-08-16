part of cube_entry;

class ScannerView {
  static bool get supported => MediaStream.supported;
  final int maxWidth;
  final int maxHeight;
  bool get isRunning => _running;
  
  final DivElement _container;
  final VideoElement _viewport;
  final ScannerOverlay _overlay;
  CanvasRenderingContext2D _context = null;
  MediaStream _stream = null;
  
  bool _running = false;
  Future _initFuture = null;
  
  ScannerView(DivElement container, {this.maxWidth: 600, this.maxHeight: 600}) :
      _container = container, _viewport = container.querySelector('video'),
      _overlay = new ScannerOverlay(container.querySelector('canvas'));
  
  Future start() {
    if (_initFuture != null) return _initFuture;
    if (!supported) {
      return new Future.error(new UnsupportedError('cannot use camera'));
    }
    
    Future f = window.navigator.getUserMedia(audio: false, video: true);
    return _initFuture = f.then((MediaStream stream) {
      _stream = stream;
      String url = Url.createObjectUrlFromStream(_stream);
      _viewport.src = url;
      return _viewport.onPlaying.first;
    }).then((_) {
      _layout();
    });
  }
  
  Future destroy() {
    if (_initFuture == null) return new Future(() => null);
    return _initFuture.then((_) {
      _viewport.pause();
      _stream.stop();
    });
  }
  
  void _layout() {
    num width = _viewport.videoWidth;
    num height = _viewport.videoHeight;
    num scale;
    if (width / maxWidth > height / maxHeight) {
      scale = maxWidth / width;
    } else {
      scale = maxHeight / height;
    }
    width *= scale;
    height *= scale;
    _container.style.width = '${width}px';
    _container.style.height = '${height}px';
    _overlay.setup(width, height);
  }
}
