import 'package:envied/envied.dart';

part 'env.g.dart'; // The generated file will have this name

@Envied(path: './.env')
abstract class Env {
  @EnviedField(varName: 'API_KEY', obfuscate: true) // Obfuscate for security
  static final String apiKey = _Env.apiKey;

  @EnviedField(varName: 'SECRET_KEY')
  static final String secretKey = _Env.secretKey;
}
