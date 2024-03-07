import 'package:chat/src/models/user.dart';
import 'package:chat/src/services/user/user_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';
import 'helpers.dart';

void main() {
  RethinkDb r = RethinkDb();
  Connection connection;
  UserService sut;

  setUp(() async {
    connection = await r.connect(host: "127.0.01", port: 28015);
    await createDb(r, connection);
    sut = UserService(r, connection);
  });

  test('create a new user document in database', () async {
    final user = User(
      username: 'test',
      photoUrl: 'url',
      active: true,
      lastseen: DateTime.now(),
    );
    final userWithId = await sut.connect(user);
    expect(userWithId.id, isNotEmpty);
  });
}
