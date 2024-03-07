import 'package:chat/src/models/user.dart';
import 'package:chat/src/services/user/user_service_contract.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

class UserService implements IUserService {
  final Connection _connection;
  final RethinkDb r;

  UserService(this.r, this._connection);

  @override
  Future<User> connect(User user) async {
    var data = user.toJson();
    if (user.id != null) data['id'] = user.id;

    final result = await r.table('users').insert(data, {
        'conflit': 'update', 
        'return_changes': true
    }).run(_connection);

    return User.fromJson(result['changes'].first['new_val']);
  }

  @override
  Future<void> disconnect(User user) {
    // TODO: implement disconnect
    throw UnimplementedError();
  }

  @override
  Future<List<User>> online() {
    // TODO: implement online
    throw UnimplementedError();
  }
}
