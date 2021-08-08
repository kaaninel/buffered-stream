A stream implementation that queues all inputs until there is a listener.

## Usage

A simple usage example:

```dart
import 'dart:async';

import 'package:buffered_stream/buffered_stream.dart';
import 'dart:io';

void main() async {
  stdin
    ..echoMode = false
    ..lineMode = false;

  var periodicStream = Stream.periodic(Duration(milliseconds: 100), (i) => i);
  var stream = BufferedStream<int>.from(periodicStream);

  StreamSubscription<int>? sub;
  stdin.listen((event) {
    if (event.first == 32) {
      if (sub != null) {
        print('Cancelled!');
        sub!.cancel();
        sub = null;
      } else {
        print('New Stream');
        sub = stream.listen((i) {
          print(i.toString());
        });
      }
    }
  });
}

```