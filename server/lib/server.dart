import "dart:io"
    show HttpServer, HttpRequest, WebSocketTransformer, WebSocket, stderr;

class Server {
  final String ip;
  final int port;

  List<WebSocket> connections = [];

  Server(this.ip, this.port);

  void logRequest(HttpRequest request) {
    print("[+]${request.connectionInfo?.remoteAddress} connected.");
  }

  void logError(Object error) {
    stderr.write("[!]Error: ${error.toString()}.\n");
  }

  void listen() async {
    try {
      final httpServer = await HttpServer.bind(ip, port);
      print("[+]Server listening on $ip:$port.");

      try {
        await httpServer.forEach((final request) async {
          logRequest(request);
          final socket = await WebSocketTransformer.upgrade(request);
          connections.add(socket);

          socket.listen((final data) {
            final dataDecoded = data.toString();
            print("[+]Recieved data: $dataDecoded.");

            for (final connection in connections) {
              if (connection.readyState == WebSocket.open) {
                connection.add(data);
              }
            }
          }, onDone: () {
            print("[-]${request.connectionInfo?.remoteAddress} disconnected.");
						connections.remove(socket);
          }, onError: logError, cancelOnError: true);
        });
      } catch (e) {
        logError(e);
      }
    } catch (e) {
      stderr.write("[!]Error: couldn't start server on $ip:$port.\n");
    }
  }
}
