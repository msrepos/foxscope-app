import 'package:foxscope/core/utils/account_storage.dart';
import 'package:foxscope/core/utils/mappable.dart';

class User extends IAccount {
  final dynamic userId;
  final String token;
  final String userName;

  User({
    required this.userId,
    required this.token,
    required this.userName,
  });

  @override
  get account_id => userId;

  @override
  get token_ => token;
}

class UserMapper extends Mappable<User> {
  @override
  User fromMap(Map<String, dynamic> values) {
    return User(
      userId: values['userId'],
      token: values['token'] ?? '',
      userName: values['userName'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toMap(User object) {
    return {
      'userId': object.userId,
      'token': object.token,
      'userName': object.userName,
    };
  }
}
