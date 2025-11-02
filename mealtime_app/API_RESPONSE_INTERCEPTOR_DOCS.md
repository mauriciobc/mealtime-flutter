# 🔄 ApiResponseInterceptor - Documentação

## 📋 Visão Geral

O `ApiResponseInterceptor` é um interceptor Dio que transforma automaticamente as respostas do backend Next.js no formato `ApiResponse` esperado pelo Flutter.

## 🎯 Problema que Resolve

### Backend Next.js retorna:
- **Arrays diretos**: `[{cat1}, {cat2}]`
- **Objetos diretos**: `{id: "1", name: "Miau"}`
- **Erros com status 2xx**: `{error: "mensagem"}`
- **Erros com status 4xx/5xx**: vários formatos

### Flutter espera:
```dart
{
  success: bool,
  data: T?,
  error: String?
}
```

## 🔧 Como Funciona

### 1. Detecção Automática

O interceptor detecta automaticamente se a resposta já está no formato `ApiResponse`:

```dart
bool _isAlreadyApiResponse(dynamic data) {
  return data is Map<String, dynamic> &&
         data.containsKey('success') &&
         data['success'] is bool;
}
```

Se detectar o campo `success` do tipo `bool`, **não transforma** a resposta.

### 2. Transformações Aplicadas

#### Caso 1: Resposta de Sucesso (status 2xx)
```dart
// Backend retorna
[{id: "1", name: "Miau"}]

// Interceptor transforma em
{
  success: true,
  data: [{id: "1", name: "Miau"}],
  error: null
}
```

#### Caso 2: Erro Disfarçado (status 2xx mas tem campo error)
```dart
// Backend retorna
{error: "Gato não encontrado"}

// Interceptor transforma em
{
  success: false,
  error: "Gato não encontrado",
  data: null
}
```

#### Caso 3: Erro HTTP (status 4xx/5xx)
```dart
// Backend retorna status 404
{error: "Não encontrado"}

// Interceptor transforma em
{
  success: false,
  error: "Não encontrado",
  data: null
}
```

#### Caso 4: Já é ApiResponse (ex: /auth/mobile)
```dart
// Backend retorna
{
  success: true,
  user: {...},
  access_token: "..."
}

// Interceptor mantém como está (não transforma)
```

## 📍 Ordem dos Interceptors

A ordem é importante! Os interceptors são executados na sequência:

```dart
dio.interceptors.addAll([
  AuthInterceptor(),           // 1. Adiciona Authorization header
  ApiResponseInterceptor(),    // 2. Transforma resposta
  LogInterceptor(),            // 3. Faz logging (debug)
]);
```

## 🧪 Casos de Teste

### Teste 1: GET /cats (array)
```dart
// Requisição
GET /cats

// Backend retorna
[
  {id: "1", name: "Miau"},
  {id: "2", name: "Felix"}
]

// Flutter recebe
ApiResponse<List<CatModel>> {
  success: true,
  data: [
    {id: "1", name: "Miau"},
    {id: "2", name: "Felix"}
  ]
}
```

### Teste 2: POST /cats (objeto)
```dart
// Requisição
POST /cats
{
  name: "Novo Gato",
  householdId: "123"
}

// Backend retorna
{
  id: "3",
  name: "Novo Gato",
  householdId: "123"
}

// Flutter recebe
ApiResponse<CatModel> {
  success: true,
  data: {
    id: "3",
    name: "Novo Gato",
    householdId: "123"
  }
}
```

### Teste 3: POST /auth/mobile (já ApiResponse)
```dart
// Requisição
POST /auth/mobile
{
  email: "user@example.com",
  password: "senha123"
}

// Backend retorna
{
  success: true,
  user: {...},
  access_token: "jwt...",
  refresh_token: "..."
}

// Flutter recebe (sem transformação)
AuthResponse {
  success: true,
  user: {...},
  accessToken: "jwt...",
  refreshToken: "..."
}
```

### Teste 4: Erro 404
```dart
// Requisição
GET /cats/999

// Backend retorna (status 404)
{error: "Gato não encontrado"}

// Flutter recebe
ApiResponse {
  success: false,
  error: "Gato não encontrado",
  data: null
}
```

### Teste 5: Erro de Conexão
```dart
// Sem internet

// Flutter recebe
ApiResponse {
  success: false,
  error: "Erro de conexão. Verifique sua internet.",
  data: null
}
```

## 🔍 Debug

O interceptor inclui logs de debug (apenas em modo debug):

```dart
[ApiResponseInterceptor] Response already in ApiResponse format
[ApiResponseInterceptor] Detected error response with status 200
[ApiResponseInterceptor] Wrapping successful response in ApiResponse format
[ApiResponseInterceptor] Transformed response for /cats
```

Para ver os logs, rode o app em modo debug:
```bash
flutter run
```

## 📝 Mensagens de Erro Padrão

O interceptor fornece mensagens amigáveis para diferentes tipos de erro:

| Tipo de Erro | Mensagem |
|--------------|----------|
| Connection Timeout | "Tempo de conexão excedido. Verifique sua internet." |
| Connection Error | "Erro de conexão. Verifique sua internet." |
| 400 Bad Request | "Requisição inválida" |
| 401 Unauthorized | "Não autorizado. Faça login novamente." |
| 403 Forbidden | "Acesso negado" |
| 404 Not Found | "Recurso não encontrado" |
| 500 Internal Error | "Erro interno do servidor" |
| 503 Service Unavailable | "Serviço temporariamente indisponível" |
| Request Canceled | "Requisição cancelada" |
| Unknown | "Erro desconhecido. Tente novamente." |

## ⚙️ Configuração

### Registro no GetIt (injection_container.dart)

```dart
import 'package:mealtime_app/core/network/api_response_interceptor.dart';

Future<void> init() async {
  final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
  
  // Adicionar interceptors na ordem correta
  dio.interceptors.add(AuthInterceptor());
  dio.interceptors.add(ApiResponseInterceptor()); // ← NOVO
  dio.interceptors.add(LogInterceptor(...));
  
  sl.registerLazySingleton(() => dio);
}
```

## ✅ Vantagens

1. **Zero mudanças no backend** - Next.js continua igual
2. **Transparente** - Services não precisam mudar
3. **Centralizado** - Toda transformação em um lugar
4. **Compatível** - Endpoints que já retornam ApiResponse continuam funcionando
5. **Testável** - Fácil de testar isoladamente
6. **Mensagens amigáveis** - Erros com mensagens em português

## 🚫 O que NÃO Fazer

❌ Não remova o interceptor - todos os services dependem dele  
❌ Não mude a ordem dos interceptors  
❌ Não transforme respostas manualmente nos services  
❌ Não crie múltiplos interceptors para o mesmo propósito  

## 📁 Arquivos Relacionados

- **Interceptor**: `lib/core/network/api_response_interceptor.dart`
- **Registro**: `lib/core/di/injection_container.dart`
- **Modelo**: `lib/core/models/api_response.dart`
- **Outros interceptors**: `lib/core/network/auth_interceptor.dart`

## 🔗 Ver Também

- [Documentação Login](./PROCESSO_LOGIN_BACKEND.md)
- [Resumo Executivo](./LOGIN_RESUMO_EXECUTIVO.md)
- [Diagramas de Fluxo](./DIAGRAMA_FLUXO_LOGIN.md)

---

**Criado em:** Janeiro 2025  
**Status:** ✅ Implementado e testado  
**Versão:** 1.0






