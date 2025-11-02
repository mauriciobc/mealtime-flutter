# 🧪 Guia de Teste - ApiResponseInterceptor

## 📋 Checklist de Testes

Use este guia para validar que o `ApiResponseInterceptor` está funcionando corretamente.

---

## ✅ Pré-requisitos

1. **Backend rodando**: Certifique-se que o backend Next.js está disponível em `https://mealtime.app.br/api`
2. **App compilado**: Execute `flutter run` no terminal
3. **Usuário logado**: Faça login no app antes de testar os endpoints protegidos

---

## 🧪 Teste 1: GET /cats (Array Direto)

### Objetivo
Verificar que um array retornado pelo backend é envolvido em `ApiResponse`.

### Passos
1. Faça login no app
2. Navegue para a tela de "Gatos" ou "Pets"
3. Observe os logs no terminal

### Resultados Esperados

**Log do interceptor:**
```
[ApiResponseInterceptor] Wrapping successful response in ApiResponse format
[ApiResponseInterceptor] Transformed response for /cats
```

**Dados carregados:**
- Lista de gatos deve aparecer na tela
- Sem erros de parsing
- Sem crashes

### Como Verificar Manualmente

Adicione um print temporário no datasource:

```dart
// lib/features/cats/data/datasources/cats_remote_datasource.dart

@override
Future<List<CatModel>> getCats() async {
  final response = await apiService.getCats();
  
  print('🔍 Response success: ${response.success}');
  print('🔍 Response data: ${response.data}');
  
  if (!response.success || response.data == null) {
    throw ServerException(response.error ?? 'Erro ao buscar gatos');
  }
  
  return response.data!;
}
```

---

## 🧪 Teste 2: POST /auth/mobile (Já ApiResponse)

### Objetivo
Garantir que respostas que já estão no formato `ApiResponse` não são transformadas novamente.

### Passos
1. Faça logout do app
2. Tente fazer login novamente
3. Observe os logs

### Resultados Esperados

**Log do interceptor:**
```
[ApiResponseInterceptor] Response already in ApiResponse format
```

**Login funcionando:**
- Login bem-sucedido
- Dados do usuário carregados
- Token salvo corretamente
- Navegação para home

### Como Verificar Manualmente

Adicione um print temporário no datasource de auth:

```dart
// lib/features/auth/data/datasources/auth_remote_datasource.dart

@override
Future<AuthResponse> login(String email, String password) async {
  final apiResponse = await apiService.login(
    LoginRequest(email: email, password: password),
  );
  
  print('🔍 Auth Response structure: ${apiResponse.data?.runtimeType}');
  print('🔍 Has access_token: ${apiResponse.data?.accessToken != null}');
  
  if (apiResponse.data == null) {
    throw ServerException('Resposta da API está vazia');
  }
  
  return apiResponse.data!;
}
```

---

## 🧪 Teste 3: POST /cats (Objeto Direto)

### Objetivo
Verificar que um objeto retornado pelo backend é envolvido em `ApiResponse`.

### Passos
1. Na tela de gatos, clique em "Adicionar Gato"
2. Preencha o formulário
3. Clique em "Salvar"
4. Observe os logs

### Resultados Esperados

**Log do interceptor:**
```
[ApiResponseInterceptor] Wrapping successful response in ApiResponse format
[ApiResponseInterceptor] Transformed response for /cats
```

**Gato criado:**
- Novo gato aparece na lista
- Sem erros de parsing
- Mensagem de sucesso exibida

---

## 🧪 Teste 4: Erro 404 (Not Found)

### Objetivo
Verificar tratamento de erro 404.

### Passos
1. Tente acessar um gato que não existe (se possível via código)
2. Ou force um erro 404 modificando temporariamente um endpoint

### Código para Forçar Erro 404:

```dart
// Adicionar temporariamente em algum lugar
final dio = sl<Dio>();
try {
  final response = await dio.get('/cats/id-que-nao-existe-999');
  print('Response: $response');
} catch (e) {
  print('🔴 Erro capturado: $e');
}
```

### Resultados Esperados

**Mensagem de erro amigável:**
```
"Recurso não encontrado"
```

**Sem crash:**
- App continua funcionando
- Mensagem de erro exibida para o usuário

---

## 🧪 Teste 5: Erro de Conexão

### Objetivo
Verificar tratamento de erro de conexão.

### Passos
1. Desabilite o Wi-Fi/dados móveis
2. Tente carregar a lista de gatos
3. Observe a mensagem de erro

### Resultados Esperados

**Mensagem de erro amigável:**
```
"Erro de conexão. Verifique sua internet."
```

**Sem crash:**
- App mostra mensagem de erro
- Botão para tentar novamente (se implementado)

---

## 🧪 Teste 6: Erro 401 (Unauthorized)

### Objetivo
Verificar tratamento de token expirado.

### Passos
1. Deixe o app aberto por mais de 1 hora (token expira)
2. OU force um erro 401 removendo temporariamente o token
3. Tente fazer uma requisição

### Código para Forçar Erro 401:

```dart
// Limpar token temporariamente
await TokenManager.clearTokens();

// Tentar fazer requisição
final catsBloc = sl<CatsBloc>();
catsBloc.add(LoadCatsEvent());
```

### Resultados Esperados

**Mensagem de erro:**
```
"Não autorizado. Faça login novamente."
```

**Ou refresh automático:**
- Se `AuthInterceptor` estiver funcionando, deve renovar o token automaticamente

---

## 📊 Resumo dos Testes

| # | Teste | Status | Observações |
|---|-------|--------|-------------|
| 1 | GET /cats (array) | ⏳ Pendente | Verificar wrapping |
| 2 | POST /auth/mobile | ⏳ Pendente | Não deve transformar |
| 3 | POST /cats (objeto) | ⏳ Pendente | Verificar wrapping |
| 4 | Erro 404 | ⏳ Pendente | Mensagem amigável |
| 5 | Erro de conexão | ⏳ Pendente | Mensagem amigável |
| 6 | Erro 401 | ⏳ Pendente | Refresh ou mensagem |

---

## 🐛 Troubleshooting

### Problema: "Não vejo os logs do interceptor"

**Solução:**
- Certifique-se que está rodando em modo debug: `flutter run`
- Verifique se `kDebugMode` está habilitado
- Procure por `[ApiResponseInterceptor]` nos logs

### Problema: "Erro de parsing JSON"

**Possível causa:**
- Backend retornando formato inesperado
- Interceptor não está registrado

**Verificar:**
```dart
// lib/core/di/injection_container.dart
dio.interceptors.add(ApiResponseInterceptor()); // ← Deve estar presente
```

### Problema: "Login não funciona mais"

**Possível causa:**
- Interceptor está transformando resposta de auth quando não deveria

**Verificar:**
- Logs devem mostrar: `Response already in ApiResponse format`
- Se não mostrar, há um bug na detecção

### Problema: "Endpoints antigos pararam de funcionar"

**Solução:**
- Verifique se o endpoint já retornava formato `ApiResponse`
- Se sim, o interceptor deve detectar e não transformar
- Adicione logs temporários para debugar

---

## 📝 Registro de Testes

Use esta seção para anotar os resultados dos testes:

**Data do teste:** _____________

**Ambiente:** 
- [ ] Desenvolvimento local
- [ ] Staging
- [ ] Produção

**Dispositivo:**
- [ ] Emulador Android
- [ ] Dispositivo Android real
- [ ] Emulador iOS
- [ ] Dispositivo iOS real

**Resultados:**

```
Teste 1 (GET /cats): ✅ / ❌
Observações: _______________________

Teste 2 (POST /auth/mobile): ✅ / ❌
Observações: _______________________

Teste 3 (POST /cats): ✅ / ❌
Observações: _______________________

Teste 4 (Erro 404): ✅ / ❌
Observações: _______________________

Teste 5 (Erro conexão): ✅ / ❌
Observações: _______________________

Teste 6 (Erro 401): ✅ / ❌
Observações: _______________________
```

---

## 🔗 Links Relacionados

- [Documentação do Interceptor](./API_RESPONSE_INTERCEPTOR_DOCS.md)
- [Plano de Implementação](./api-response-interceptor.plan.md)

---

**Criado em:** Janeiro 2025






