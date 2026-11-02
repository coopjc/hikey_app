import 'package:flutter/foundation.dart';

import '../models/hike_stats.dart';
import '../services/user_service.dart';

class UserController extends ChangeNotifier {
  UserController({required UserService userService}) : _user = userService;

  final UserService _user;

  Future<HikeStats> getStats() => _user.getStats();
}
