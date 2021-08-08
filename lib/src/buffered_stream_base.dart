import 'dart:async';
import 'dart:collection';

class BufferedStream<T> extends Stream<T> implements StreamConsumer<T> {
  final Queue<T> _buffer = Queue<T>();
  final StreamController<T> _controller = StreamController();
  late Stream<T> _stream;
  int _subCount = 0;
  bool _pushing = false;

  BufferedStream() {
    _stream = _controller.stream.asBroadcastStream(onListen: (sub) async {
      _subCount++;
      _push();
    }, onCancel: (sub) {
      _subCount--;
    });
  }

  factory BufferedStream.from(Stream<T> stream) {
    var buff = BufferedStream<T>();
    stream.pipe(buff);
    return buff;
  }

  void _push() {
    if (_pushing) return;
    _pushing = true;
    while (_buffer.isNotEmpty && _subCount > 0) {
      _controller.add(_buffer.removeFirst());
    }
    _pushing = false;
  }

  @override
  StreamSubscription<T> listen(void Function(T value)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return _stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  Future addStream(Stream<T> stream) {
    var c = Completer();
    stream.listen((event) {
      _buffer.add(event);
      _push();
    }, onDone: c.complete);
    return c.future;
  }

  @override
  Future close() {
    _controller.close();
    return _controller.done;
  }
}
