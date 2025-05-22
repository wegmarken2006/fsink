import 'dart:isolate';
import 'utils.dart';

typedef TxChan = SendPort;

class Thread {
  late Isolate isolate;
  late ReceivePort receivePort;
  late SendPort sendPort;
  late ReceivePort exitPort;
  //var uThreadStart = Isolate.spawn;
  bool isRunning = false;

  Thread();

  /// Input "fun" must be static, must have TxChan input parameter.
  void uThreadStart(Function(TxChan) fun, TxChan par) async {
    if (!isRunning) {
      isRunning = true;
      isolate = await Isolate.spawn(fun, par, onExit: exitPort.sendPort);
    }
  }

  void uThreadStop() {
    isolate.kill();
    receivePort.close();
    exitPort.close();
    isRunning = false;
  }

  void uRxChanCallback(Function(Any) onReceive) {
    receivePort.listen(onReceive);
  }

  void uSend(Any message) {
    sendPort.send(message);
  }
}

Thread uThreadInit() {
  var receivePort = ReceivePort();
  //var isolate = await Isolate.spawn(fun!, par);
  //receivePort.listen(onReceive);

  var thread = Thread();
  thread.receivePort = receivePort;
  thread.exitPort = ReceivePort();
  thread.sendPort = receivePort.sendPort;

  thread.exitPort.listen((_) {
    thread.isRunning = false;
  });

  return thread;
}
