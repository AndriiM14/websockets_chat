import 'package:server/server.dart' show Server;

void main(List<String> args) {
	final server = Server("localhost", 8080);
	server.listen();
}
