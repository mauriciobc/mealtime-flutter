# 💻 Login - Exemplos de Código Práticos

> **Exemplos prontos para usar e adaptar**

---

## 📱 Frontend (Flutter/Dart)

### 1. Fazer Login (Completo)

```dart
// lib/features/auth/presentation/pages/login_page.dart

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    // Validar formulário
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Chamar repositório
      final result = await ref.read(authRepositoryProvider).login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      result.fold(
        // Erro
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: Colors.red,
            ),
          );
        },
        // Sucesso
        (user) {
          // Atualizar estado global
          ref.read(currentUserProvider.notifier).state = user;
          
          // Navegar para home
          context.go('/home');
        },
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Campo de Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite seu email';
                  }
                  if (!value.contains('@')) {
                    return 'Email inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Campo de Senha
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite sua senha';
                  }
                  if (value.length < 6) {
                    return 'Senha deve ter pelo menos 6 caracteres';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _handleLogin(),
              ),
              const SizedBox(height: 24),
              
              // Botão de Login
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Entrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
```

---

### 2. Repository (Clean Architecture)

```dart
// lib/features/auth/data/repositories/auth_repository_impl.dart

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User>> login(
    String email, 
    String password,
  ) async {
    try {
      // 1. Fazer requisição para backend
      final authResponse = await remoteDataSource.login(email, password);

      // 2. Verificar sucesso
      if (!authResponse.isSuccess) {
        return Left(ServerFailure(
          authResponse.error ?? 'Falha no login'
        ));
      }

      // 3. Validar dados
      if (authResponse.user == null || authResponse.accessToken == null) {
        return Left(ServerFailure('Dados de autenticação inválidos'));
      }

      // 4. Salvar tokens localmente
      await localDataSource.saveTokens(
        authResponse.accessToken!,
        authResponse.refreshToken ?? '',
      );

      // 5. Salvar usuário localmente
      await localDataSource.saveUser(authResponse.user!);

      // 6. Retornar entidade
      return Right(authResponse.user!.toEntity());

    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: ${e.toString()}'));
    }
  }
}
```

---

### 3. API Service (Retrofit)

```dart
// lib/services/api/auth_api_service.dart

@RestApi()
abstract class AuthApiService {
  factory AuthApiService(Dio dio, {String baseUrl}) = _AuthApiService;

  @POST('/auth/mobile')
  Future<ApiResponse<AuthResponse>> login(@Body() LoginRequest request);
}

// Modelo de requisição
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}

// Modelo de resposta
@JsonSerializable()
class AuthResponse {
  final bool? success;
  
  @JsonKey(name: 'access_token')
  final String? accessToken;
  
  @JsonKey(name: 'refresh_token')
  final String? refreshToken;
  
  @JsonKey(name: 'expires_in')
  final int? expiresIn;
  
  @JsonKey(name: 'token_type')
  final String? tokenType;
  
  final UserModel? user;
  final String? error;

  AuthResponse({
    this.success,
    this.accessToken,
    this.refreshToken,
    this.expiresIn,
    this.tokenType,
    this.user,
    this.error,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  bool get isSuccess => accessToken != null && accessToken!.isNotEmpty;
  bool get hasError => error != null;
}
```

---

### 4. Auth Interceptor (Adiciona token automaticamente)

```dart
// lib/core/network/auth_interceptor.dart

class AuthInterceptor extends Interceptor {
  final AuthLocalDataSource localDataSource;

  AuthInterceptor(this.localDataSource);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Buscar token salvo
    final token = await localDataSource.getAccessToken();

    // Adicionar ao header se existir
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Se erro 401 (token expirado)
    if (err.response?.statusCode == 401) {
      try {
        // Tentar renovar token
        final refreshToken = await localDataSource.getRefreshToken();
        
        if (refreshToken != null) {
          // Chamar endpoint de refresh
          final dio = Dio();
          final response = await dio.put(
            'https://mealtime.app.br/api/auth/mobile',
            data: {'refresh_token': refreshToken},
          );

          // Salvar novos tokens
          final newAccessToken = response.data['access_token'];
          final newRefreshToken = response.data['refresh_token'];
          
          await localDataSource.saveTokens(
            newAccessToken,
            newRefreshToken,
          );

          // Repetir requisição original com novo token
          err.requestOptions.headers['Authorization'] = 
              'Bearer $newAccessToken';
          
          final retry = await dio.fetch(err.requestOptions);
          return handler.resolve(retry);
        }
      } catch (e) {
        // Se falhar, deslogar usuário
        await localDataSource.clearTokens();
        await localDataSource.clearUser();
      }
    }

    handler.next(err);
  }
}
```

---

### 5. Local Storage (SharedPreferences)

```dart
// lib/features/auth/data/datasources/auth_local_datasource.dart

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences prefs;

  AuthLocalDataSourceImpl(this.prefs);

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  @override
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  @override
  Future<String?> getAccessToken() async {
    return prefs.getString(_accessTokenKey);
  }

  @override
  Future<String?> getRefreshToken() async {
    return prefs.getString(_refreshTokenKey);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await prefs.setString(_userKey, userJson);
  }

  @override
  Future<UserModel?> getUser() async {
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;
    
    return UserModel.fromJson(jsonDecode(userJson));
  }

  @override
  Future<void> clearTokens() async {
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  @override
  Future<void> clearUser() async {
    await prefs.remove(_userKey);
  }
}
```

---

### 6. Verificar se Usuário Está Logado

```dart
// lib/core/auth/auth_guard.dart

class AuthGuard {
  final AuthLocalDataSource localDataSource;

  AuthGuard(this.localDataSource);

  Future<bool> isAuthenticated() async {
    final token = await localDataSource.getAccessToken();
    final user = await localDataSource.getUser();
    
    return token != null && 
           token.isNotEmpty && 
           user != null;
  }

  Future<User?> getCurrentUser() async {
    final userModel = await localDataSource.getUser();
    return userModel?.toEntity();
  }
}

// Uso no GoRouter
GoRouter(
  redirect: (context, state) async {
    final authGuard = getIt<AuthGuard>();
    final isAuth = await authGuard.isAuthenticated();
    final isLoginPage = state.location == '/login';

    // Se não está autenticado e não está na página de login
    if (!isAuth && !isLoginPage) {
      return '/login';
    }

    // Se está autenticado e está na página de login
    if (isAuth && isLoginPage) {
      return '/home';
    }

    return null; // Tudo OK
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => LoginPage()),
    GoRoute(path: '/home', builder: (context, state) => HomePage()),
  ],
);
```

---

## 🌐 Backend (TypeScript/Next.js)

### 1. Endpoint de Login Completo

```typescript
// app/api/auth/mobile/route.ts

import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@/utils/supabase/server';
import { logger } from '@/lib/monitoring/logger';
import prisma from '@/lib/prisma';

export async function POST(request: NextRequest) {
  try {
    // 1. Extrair dados do body
    const { email, password } = await request.json();

    // 2. Validar campos
    if (!email || !password) {
      return NextResponse.json(
        { success: false, error: 'Email e senha são obrigatórios' },
        { status: 400 }
      );
    }

    // 3. Criar cliente Supabase
    const supabase = await createClient();
    
    // 4. Autenticar no Supabase
    const { data: authData, error: authError } = 
      await supabase.auth.signInWithPassword({
        email,
        password,
      });

    // 5. Verificar erros de autenticação
    if (authError || !authData.user) {
      logger.warn('[Mobile Auth] Login failed', { 
        email, 
        error: authError?.message 
      });
      
      return NextResponse.json(
        { success: false, error: 'Credenciais inválidas' },
        { status: 401 }
      );
    }

    // 6. Buscar dados completos no Prisma
    const prismaUser = await prisma.user.findUnique({
      where: { auth_id: authData.user.id },
      include: {
        household: {
          include: {
            household_members: {
              include: {
                user: {
                  select: {
                    id: true,
                    full_name: true,
                    email: true,
                  }
                }
              }
            }
          }
        }
      }
    });

    // 7. Verificar se usuário existe no Prisma
    if (!prismaUser) {
      logger.error('[Mobile Auth] Prisma user not found', { 
        authId: authData.user.id 
      });
      
      return NextResponse.json(
        { success: false, error: 'Usuário não encontrado no sistema' },
        { status: 404 }
      );
    }

    // 8. Preparar dados do usuário
    const userData = {
      id: prismaUser.id,
      auth_id: prismaUser.auth_id,
      full_name: prismaUser.full_name,
      email: prismaUser.email,
      household_id: prismaUser.householdId,
      household: prismaUser.household ? {
        id: prismaUser.household.id,
        name: prismaUser.household.name,
        members: prismaUser.household.household_members
          .filter(member => member.user !== null)
          .map(member => ({
            id: member.user!.id,
            name: member.user!.full_name,
            email: member.user!.email,
            role: member.role
          }))
      } : null
    };

    // 9. Validar tokens
    if (!authData.session?.access_token || !authData.session?.refresh_token) {
      logger.error('[Mobile Auth] Tokens missing', { userId: prismaUser.id });
      return NextResponse.json(
        { success: false, error: 'Falha na geração de tokens' },
        { status: 401 }
      );
    }

    // 10. Log de sucesso
    logger.info('[Mobile Auth] Login successful', { 
      userId: prismaUser.id,
      email: prismaUser.email 
    });

    // 11. Retornar resposta de sucesso
    return NextResponse.json({
      success: true,
      user: userData,
      access_token: authData.session.access_token,
      refresh_token: authData.session.refresh_token,
      expires_in: authData.session.expires_in || 3600,
      token_type: 'Bearer'
    });

  } catch (error) {
    // 12. Tratamento de erros
    logger.error('[Mobile Auth] Unexpected error', { 
      error: error.message,
      stack: error.stack 
    });
    
    return NextResponse.json(
      { success: false, error: 'Erro interno do servidor' },
      { status: 500 }
    );
  }
}
```

---

### 2. Endpoint de Refresh Token

```typescript
// app/api/auth/mobile/route.ts (método PUT)

export async function PUT(request: NextRequest) {
  try {
    const { refresh_token } = await request.json();

    if (!refresh_token) {
      return NextResponse.json(
        { success: false, error: 'Refresh token é obrigatório' },
        { status: 400 }
      );
    }

    const supabase = await createClient();
    
    const { data: refreshData, error: refreshError } = 
      await supabase.auth.refreshSession({ refresh_token });

    if (refreshError || !refreshData.session) {
      logger.warn('[Mobile Auth] Token refresh failed', { 
        error: refreshError?.message 
      });
      
      return NextResponse.json(
        { success: false, error: 'Token de renovação inválido' },
        { status: 401 }
      );
    }

    return NextResponse.json({
      success: true,
      access_token: refreshData.session.access_token,
      refresh_token: refreshData.session.refresh_token,
      expires_in: refreshData.session.expires_in,
      token_type: 'Bearer'
    });

  } catch (error) {
    logger.error('[Mobile Auth] Refresh token error', { 
      error: error.message 
    });
    
    return NextResponse.json(
      { success: false, error: 'Erro interno do servidor' },
      { status: 500 }
    );
  }
}
```

---

## 🧪 Testes

### 1. Teste Unitário (Flutter)

```dart
// test/features/auth/data/repositories/auth_repository_impl_test.dart

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  group('login', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';
    
    final tAuthResponse = AuthResponse(
      success: true,
      accessToken: 'access_token',
      refreshToken: 'refresh_token',
      user: UserModel(
        id: '123',
        email: tEmail,
        fullName: 'Test User',
      ),
    );

    test('deve retornar User quando login bem-sucedido', () async {
      // arrange
      when(() => mockRemoteDataSource.login(tEmail, tPassword))
          .thenAnswer((_) async => tAuthResponse);
      when(() => mockLocalDataSource.saveTokens(any(), any()))
          .thenAnswer((_) async => {});
      when(() => mockLocalDataSource.saveUser(any()))
          .thenAnswer((_) async => {});

      // act
      final result = await repository.login(tEmail, tPassword);

      // assert
      expect(result.isRight(), true);
      verify(() => mockRemoteDataSource.login(tEmail, tPassword));
      verify(() => mockLocalDataSource.saveTokens(
        tAuthResponse.accessToken!,
        tAuthResponse.refreshToken!,
      ));
      verify(() => mockLocalDataSource.saveUser(tAuthResponse.user!));
    });

    test('deve retornar ServerFailure quando credenciais inválidas', () async {
      // arrange
      when(() => mockRemoteDataSource.login(tEmail, tPassword))
          .thenThrow(ServerException('Credenciais inválidas'));

      // act
      final result = await repository.login(tEmail, tPassword);

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });
}
```

---

### 2. Teste de Integração (Backend)

```typescript
// __tests__/api/auth/mobile.test.ts

describe('POST /api/auth/mobile', () => {
  it('deve retornar 200 e tokens quando credenciais válidas', async () => {
    const response = await request(app)
      .post('/api/auth/mobile')
      .send({
        email: 'test@example.com',
        password: 'password123',
      });

    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('success', true);
    expect(response.body).toHaveProperty('access_token');
    expect(response.body).toHaveProperty('refresh_token');
    expect(response.body).toHaveProperty('user');
    expect(response.body.user).toHaveProperty('id');
    expect(response.body.user).toHaveProperty('email', 'test@example.com');
  });

  it('deve retornar 401 quando credenciais inválidas', async () => {
    const response = await request(app)
      .post('/api/auth/mobile')
      .send({
        email: 'test@example.com',
        password: 'wrong_password',
      });

    expect(response.status).toBe(401);
    expect(response.body).toHaveProperty('success', false);
    expect(response.body).toHaveProperty('error', 'Credenciais inválidas');
  });

  it('deve retornar 400 quando campos faltando', async () => {
    const response = await request(app)
      .post('/api/auth/mobile')
      .send({
        email: 'test@example.com',
      });

    expect(response.status).toBe(400);
    expect(response.body).toHaveProperty('success', false);
    expect(response.body).toHaveProperty('error');
  });
});
```

---

## 🔗 Links Relacionados

- [Documentação Completa](./PROCESSO_LOGIN_BACKEND.md)
- [Diagramas de Fluxo](./DIAGRAMA_FLUXO_LOGIN.md)
- [Resumo Executivo](./LOGIN_RESUMO_EXECUTIVO.md)

---

**Última atualização:** Janeiro 2025






