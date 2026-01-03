import 'package:envied/envied.dart';

part 'env.g.dart'; // The generated file will have this name
/*
Commands to run after changing this file/after adding new keys to .env

dart run build_runner build --delete-conflicting-outputs
-> This command forces Flutter to look at your .env file again, find PK_TEST, and write the new getter into env.g.dart.
*/
@Envied(path: './.env')
abstract class Env {
  @EnviedField(varName: 'API_KEY', obfuscate: true) // Obfuscate for security
  static final String apiKey = _Env.apiKey;

  @EnviedField(varName: 'SECRET_KEY')
  static final String secretKey = _Env.secretKey;

  
  @EnviedField(varName: 'PK_TEST', obfuscate: true)
  static final String pktest = _Env.pktest;
}
