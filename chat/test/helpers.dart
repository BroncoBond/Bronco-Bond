import 'package:rethink_db_ns/rethink_db_ns.dart';

Future<void> createDb(RethinkDb r, Connection connection) async {
  await r.dbCreate('test').run(connection).catchError((err) => {});
}
