import 'package:flutter_test/flutter_test.dart';
import 'package:mealtime_app/services/api/auth_api_service.dart';

void main() {
  group('AuthResponse', () {
    test('deve deserializar resposta de sucesso da API Supabase', () {
      // Arrange - Formato real retornado pela API
      final jsonMap = {
        'access_token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
        'token_type': 'bearer',
        'expires_in': 3600,
        'expires_at': 1760195881,
        'refresh_token': 'pb5saderevva',
        'user': {
          'id': '915a9f01-d515-4b60-bf24-20b7c2f54c63',
          'auth_id': '915a9f01-d515-4b60-bf24-20b7c2f54c63',
          'full_name': 'Usuario Teste',
          'email': 'testapi@email.com',
          'created_at': '2025-10-11T14:16:46.005256Z',
          'updated_at': '2025-10-11T14:18:01.160645Z',
          'is_email_verified': true,
        }
      };

      // Act
      final result = AuthResponse.fromJson(jsonMap);

      // Assert
      expect(result.isSuccess, true);
      expect(result.hasError, false);
      expect(result.accessToken, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...');
      expect(result.tokenType, 'bearer');
      expect(result.expiresIn, 3600);
      expect(result.expiresAt, 1760195881);
      expect(result.refreshToken, 'pb5saderevva');
      expect(result.user, isNotNull);
      expect(result.user!.email, 'testapi@email.com');
    });

    test('deve deserializar resposta de erro 401 (credenciais inválidas)', () {
      // Arrange
      final jsonMap = {
        'success': false,
        'error': 'Credenciais inválidas',
      };

      // Act
      final result = AuthResponse.fromJson(jsonMap);

      // Assert
      expect(result.isSuccess, false);
      expect(result.hasError, true);
      expect(result.error, 'Credenciais inválidas');
      expect(result.success, false);
      expect(result.accessToken, isNull);
    });

    test('deve deserializar resposta de erro 400 (campos faltando)', () {
      // Arrange
      final jsonMap = {
        'success': false,
        'error': 'Email e senha são obrigatórios',
      };

      // Act
      final result = AuthResponse.fromJson(jsonMap);

      // Assert
      expect(result.isSuccess, false);
      expect(result.hasError, true);
      expect(result.error, 'Email e senha são obrigatórios');
      expect(result.accessToken, isNull);
    });

    test('deve deserializar resposta de registro que requer confirmação', () {
      // Arrange
      final jsonMap = {
        'success': false,
        'error': 'Verifique seu email para confirmar a conta',
        'requires_email_confirmation': true,
      };

      // Act
      final result = AuthResponse.fromJson(jsonMap);

      // Assert
      expect(result.isSuccess, false);
      expect(result.hasError, true);
      expect(result.requiresEmailConfirmation, true);
      expect(result.error, contains('email'));
    });

    test('deve identificar sucesso corretamente com accessToken presente', () {
      // Arrange
      final jsonMap = {
        'access_token': 'token123',
        'token_type': 'bearer',
        'expires_in': 3600,
      };

      // Act
      final result = AuthResponse.fromJson(jsonMap);

      // Assert
      expect(result.isSuccess, true);
      expect(result.success, isNull); // Campo success não existe em sucesso
    });

    test('deve identificar erro corretamente sem accessToken', () {
      // Arrange
      final jsonMap = {
        'success': false,
        'error': 'Algum erro',
      };

      // Act
      final result = AuthResponse.fromJson(jsonMap);

      // Assert
      expect(result.isSuccess, false);
      expect(result.hasError, true);
    });

    test('deve serializar para JSON corretamente', () {
      // Arrange
      final authResponse = AuthResponse(
        accessToken: 'token123',
        tokenType: 'bearer',
        expiresIn: 3600,
        expiresAt: 1234567890,
        refreshToken: 'refresh123',
      );

      // Act
      final result = authResponse.toJson();

      // Assert
      expect(result['access_token'], 'token123');
      expect(result['token_type'], 'bearer');
      expect(result['expires_in'], 3600);
      expect(result['expires_at'], 1234567890);
      expect(result['refresh_token'], 'refresh123');
    });
  });
}


