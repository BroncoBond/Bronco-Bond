import 'package:jwt_decoder/jwt_decoder.dart';

String getUserIDFromToken(String token) {
  try {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    return decodedToken['data']['_id'];
  } catch (e) {
    print('Error decoding token: $e');
    return '';
  }
}
