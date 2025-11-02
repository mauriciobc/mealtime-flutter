# 🚀 Login - Resumo Executivo

> **Documento simplificado para consulta rápida**

---

## ⚡ TL;DR (Resumo Ultra-Rápido)

O app Flutter envia email/senha para o backend → Backend valida no Supabase → Busca dados completos no banco → Retorna user + tokens → App salva localmente → Usuário logado! 🎉

---

## 📋 Checklist Rápido

### O que o Frontend envia:
```json
POST https://mealtime.app.br/api/auth/mobile
{
  "email": "usuario@exemplo.com",
  "password": "senha123"
}
```

### O que o Backend retorna (sucesso):
```json
{
  "success": true,
  "user": {
    "id": "uuid",
    "full_name": "Nome Completo",
    "email": "email@exemplo.com",
    "household_id": "uuid",
    "household": { 
      "id": "uuid",
      "name": "Nome da Casa",
      "members": [...]
    }
  },
  "access_token": "jwt_token_aqui",
  "refresh_token": "refresh_token_aqui",
  "expires_in": 3600,
  "token_type": "Bearer"
}
```

### O que o Backend retorna (erro):
```json
{
  "success": false,
  "error": "Credenciais inválidas"
}
```

---

## 🎯 Códigos HTTP

| Código | Significado | Ação do App |
|--------|-------------|-------------|
| 200 | ✅ Login OK | Salva tokens e navega para Home |
| 400 | ⚠️ Campos faltando | Mostra "Preencha todos os campos" |
| 401 | ❌ Senha errada | Mostra "Email ou senha incorretos" |
| 404 | ❓ User não existe | Mostra "Usuário não encontrado" |
| 500 | 🔥 Erro servidor | Mostra "Erro no servidor, tente novamente" |

---

## 🔐 Como Usar o Token

Todas as requisições após login devem incluir:

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

O `AuthInterceptor` do Flutter faz isso automaticamente.

---

## ⏱️ Quando o Token Expira

- **Tempo de vida:** 1 hora (3600 segundos)
- **O que acontece:** Backend retorna 401
- **O que o app faz:** Usa `refresh_token` para pegar novo `access_token`
- **Endpoint refresh:** `PUT /api/auth/mobile` com `{ "refresh_token": "..." }`

---

## 🗂️ O que é Salvo Localmente

Após login bem-sucedido, o app salva:

1. **access_token** → Para autenticar requisições
2. **refresh_token** → Para renovar quando expirar
3. **User data** → Nome, email, household, etc.

**Storage:** SharedPreferences ou similar

---

## 🔍 Debugging Rápido

### Ver se está autenticado:
```dart
final token = await localDataSource.getAccessToken();
print('Token: ${token != null ? "✅ Existe" : "❌ Null"}');
```

### Ver dados do usuário:
```dart
final user = await localDataSource.getUser();
print('User: ${user?.fullName ?? "❌ Não logado"}');
```

### Decodificar token JWT:
Cole o token em https://jwt.io

---

## 🏗️ Arquivos Importantes

### Backend (TypeScript)
```
app/api/auth/mobile/route.ts          ← Login endpoint
app/api/auth/mobile/register/route.ts ← Registro
```

### Flutter (Dart)
```
lib/features/auth/data/repositories/auth_repository_impl.dart
lib/features/auth/data/datasources/auth_remote_datasource.dart
lib/services/api/auth_api_service.dart
lib/core/network/auth_interceptor.dart
```

---

## 🔄 Fluxo Simplificado

```
1️⃣  Usuário digita email/senha
         ↓
2️⃣  App valida campos
         ↓
3️⃣  App envia POST /api/auth/mobile
         ↓
4️⃣  Backend valida no Supabase
         ↓
5️⃣  Backend busca dados no Prisma
         ↓
6️⃣  Backend retorna JSON
         ↓
7️⃣  App salva tokens + dados
         ↓
8️⃣  App navega para Home
         ↓
9️⃣  Login completo! 🎉
```

---

## 📊 Dados Retornados do Backend

### User Object
```dart
{
  id: String             // UUID do usuário
  auth_id: String        // UUID do Supabase Auth
  full_name: String      // Nome completo
  email: String          // Email
  household_id: String?  // ID da casa (pode ser null)
  household: {           // Dados da casa (pode ser null)
    id: String
    name: String
    members: [           // Lista de membros
      {
        id: String
        name: String
        email: String
        role: String     // 'admin' ou 'member'
      }
    ]
  }
}
```

### Tokens
- **access_token**: JWT para autenticação (validade: 1h)
- **refresh_token**: Token para renovação (validade: 30 dias)
- **expires_in**: Segundos até expirar (3600)

---

## ❌ Tratamento de Erros

### No Flutter
```dart
try {
  final user = await authRepository.login(email, password);
  // Sucesso!
} on ServerFailure catch (failure) {
  // Mostra: failure.message
} on NetworkFailure catch (failure) {
  // Mostra: "Sem conexão com a internet"
}
```

### Mensagens Comuns
- "Credenciais inválidas" → Email ou senha errados
- "Email e senha são obrigatórios" → Campos vazios
- "Usuário não encontrado no sistema" → Bug no backend
- "Erro interno do servidor" → Backend caiu

---

## 🔒 Segurança

✅ **O que está seguro:**
- Senhas hasheadas (bcrypt via Supabase)
- Tokens JWT assinados
- HTTPS obrigatório
- Tokens com expiração

⚠️ **Cuidados:**
- Nunca logar tokens no console em produção
- Limpar tokens ao fazer logout
- Não armazenar senha localmente

---

## 🧪 Testando

### Teste Manual (Postman/Insomnia)
```bash
POST https://mealtime.app.br/api/auth/mobile
Content-Type: application/json

{
  "email": "seu_email@teste.com",
  "password": "sua_senha"
}
```

### Teste no Flutter
```dart
test('login deve retornar user quando credenciais válidas', () async {
  // Arrange
  final email = 'teste@exemplo.com';
  final password = 'senha123';
  
  // Act
  final result = await authRepository.login(email, password);
  
  // Assert
  expect(result.isRight(), true);
});
```

---

## 📞 Contatos para Dúvidas

- **Backend**: Verificar `app/api/auth/mobile/route.ts`
- **Flutter**: Verificar `lib/features/auth/`
- **Documentação completa**: `PROCESSO_LOGIN_BACKEND.md`
- **Diagramas**: `DIAGRAMA_FLUXO_LOGIN.md`

---

## 🔗 Links Úteis

- [Supabase Auth Docs](https://supabase.com/docs/guides/auth)
- [JWT.io - Decodificador](https://jwt.io)
- [Postman - Teste de APIs](https://www.postman.com)

---

## ✨ Dicas Pro

1. **Token inválido?** Limpe o cache do app e faça login novamente
2. **Erro 401 constante?** Verifique se o interceptor está configurado
3. **Usuário não encontrado?** Backend pode estar inconsistente com Supabase
4. **Lento no login?** Verifique queries N+1 no backend (include do Prisma)

---

**Última atualização:** Janeiro 2025  
**Versão:** 1.0  
**Autor:** Documentação gerada via GitHub MCP






