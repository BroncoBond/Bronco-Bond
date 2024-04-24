import 'package:jwt_decoder/jwt_decoder.dart';

String getUserIDFromToken(String token) {
  try {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    print('$decodedToken');
    return decodedToken['data'];
  } catch (e) {
    print('Error decoding token: $e');
    return '';
  }
}
