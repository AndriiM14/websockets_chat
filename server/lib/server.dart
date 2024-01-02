import "dart:io" show HttpServer, stderr;
import "dart:convert" show utf8;

class Server {
  final String ip;
  final int port;

  Server(this.ip, this.port);

  void listen() async {
    try {
      final httpServer = await HttpServer.bind(ip, port);
      print("[+]Server listening on $ip:$port");

      try {
        await httpServer.forEach((final request) async {
          switch (request.method) {
            case "GET":
              request.response.write("Hello from dart server\n");
              break;
            case "POST":
              final body = await utf8.decodeStream(request);
              request.response.write("${body.split("").reversed.join()}\n");
              break;
          }
          request.response.close();
        });
      } catch (e) {
        stderr.write("[!]Error: ${e.toString()}\n");
      }
    } catch (e) {
      stderr.write("[!]Error: couldn't start server on $ip:$port\n");
    }
  }
}
