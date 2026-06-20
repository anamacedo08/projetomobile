import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static late String appEnv;
  static late String dbName;
  static late int dbVersion;
  static late String githubSyncToken;
  static late String paymentGatewayKey;
  static late String pushProviderConfig;

  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");

    appEnv = dotenv.get('APP_ENV', fallback: 'development');
    dbName = dotenv.get('DB_NAME', fallback: 'artesanal.db');
    dbVersion = int.parse(dotenv.get('DB_VERSION', fallback: '1'));
    githubSyncToken = dotenv.get('GITHUB_SYNC_TOKEN', fallback: '');
    paymentGatewayKey = dotenv.get('PAYMENT_GATEWAY_KEY', fallback: '');
    pushProviderConfig = dotenv.get('PUSH_PROVIDER_CONFIG', fallback: '');
  }
}
