# 📚 Documentação Completa - Sistema de Login Mealtime

> **Índice centralizado de toda a documentação do processo de autenticação**

---

## 📖 Visão Geral

Esta documentação explica detalhadamente como funciona o processo de login no aplicativo Mealtime, desde o momento em que o usuário digita suas credenciais até receber os dados de autenticação do backend.

### 🎯 O que você encontrará aqui:
- ✅ Fluxo completo de autenticação
- ✅ Estrutura de requisições e respostas
- ✅ Código-fonte do backend (TypeScript)
- ✅ Código-fonte do frontend (Flutter/Dart)
- ✅ Diagramas visuais do fluxo
- ✅ Exemplos práticos prontos para usar
- ✅ Guia de debugging e troubleshooting

---

## 📑 Documentos Disponíveis

### 1. 📘 [Processo de Login - Documentação Completa](./PROCESSO_LOGIN_BACKEND.md)
**Descrição:** Documentação técnica detalhada do processo de login  
**Recomendado para:** Desenvolvedores que precisam entender o sistema completo  
**Conteúdo:**
- Endpoint e métodos HTTP
- Estrutura de requisição e resposta JSON
- Processamento no backend (TypeScript)
- Processamento no frontend (Flutter)
- Armazenamento local de tokens
- Sistema de refresh token
- Tratamento de erros
- Tecnologias utilizadas

**📄 [Abrir documentação completa →](./PROCESSO_LOGIN_BACKEND.md)**

---

### 2. 📊 [Diagramas de Fluxo](./DIAGRAMA_FLUXO_LOGIN.md)
**Descrição:** Visualização gráfica de todo o processo com diagramas Mermaid  
**Recomendado para:** Desenvolvedores visuais, apresentações, onboarding  
**Conteúdo:**
- Sequence diagram do fluxo completo
- Fluxo de uso do token
- Arquitetura do sistema
- Estrutura de dados (class diagram)
- Estados do login (state machine)
- Estrutura do JWT token
- Ciclo de vida do token
- Comparação Login vs Registro

**📄 [Abrir diagramas →](./DIAGRAMA_FLUXO_LOGIN.md)**

---

### 3. ⚡ [Resumo Executivo](./LOGIN_RESUMO_EXECUTIVO.md)
**Descrição:** Guia rápido para consulta imediata  
**Recomendado para:** Consulta rápida, debugging, referência  
**Conteúdo:**
- TL;DR do processo
- Checklist de requisição/resposta
- Códigos HTTP e significados
- Como usar o token
- Quando o token expira
- O que é salvo localmente
- Debugging rápido
- Arquivos importantes
- Fluxo simplificado
- Tratamento de erros
- Segurança
- Testes básicos

**📄 [Abrir resumo →](./LOGIN_RESUMO_EXECUTIVO.md)**

---

### 4. 💻 [Exemplos de Código](./LOGIN_EXEMPLOS_CODIGO.md)
**Descrição:** Código-fonte pronto para usar e adaptar  
**Recomendado para:** Implementação prática, referência de código  
**Conteúdo:**

#### Frontend (Flutter/Dart):
- ✅ Tela de login completa
- ✅ Repository pattern
- ✅ API Service com Retrofit
- ✅ Auth Interceptor
- ✅ Local Storage (SharedPreferences)
- ✅ Verificação de autenticação
- ✅ Guard de rotas

#### Backend (TypeScript/Next.js):
- ✅ Endpoint de login completo
- ✅ Endpoint de refresh token
- ✅ Integração Supabase Auth
- ✅ Queries Prisma
- ✅ Tratamento de erros

#### Testes:
- ✅ Testes unitários (Flutter)
- ✅ Testes de integração (Backend)

**📄 [Abrir exemplos de código →](./LOGIN_EXEMPLOS_CODIGO.md)**

---

## 🚀 Como Usar Esta Documentação

### Para Desenvolvedores Iniciantes:
1. Comece pelo **[Resumo Executivo](./LOGIN_RESUMO_EXECUTIVO.md)** para ter uma visão geral
2. Visualize os **[Diagramas de Fluxo](./DIAGRAMA_FLUXO_LOGIN.md)** para entender o processo visualmente
3. Leia a **[Documentação Completa](./PROCESSO_LOGIN_BACKEND.md)** para detalhes técnicos
4. Use os **[Exemplos de Código](./LOGIN_EXEMPLOS_CODIGO.md)** como referência na implementação

### Para Desenvolvedores Experientes:
1. Vá direto aos **[Exemplos de Código](./LOGIN_EXEMPLOS_CODIGO.md)**
2. Consulte o **[Resumo Executivo](./LOGIN_RESUMO_EXECUTIVO.md)** quando precisar
3. Use os **[Diagramas](./DIAGRAMA_FLUXO_LOGIN.md)** para documentação e apresentações

### Para Debugging:
1. Vá direto ao **[Resumo Executivo - Seção Debugging](./LOGIN_RESUMO_EXECUTIVO.md#-debugging-rápido)**
2. Confira os códigos HTTP na **[Documentação Completa](./PROCESSO_LOGIN_BACKEND.md#-respostas-de-erro)**
3. Veja o **[Diagrama de Estados](./DIAGRAMA_FLUXO_LOGIN.md#-estados-do-login)** para entender onde está o problema

### Para Apresentações:
1. Use os **[Diagramas de Fluxo](./DIAGRAMA_FLUXO_LOGIN.md)** nas suas slides
2. Extraia trechos do **[Resumo Executivo](./LOGIN_RESUMO_EXECUTIVO.md)** para pontos-chave
3. Mostre exemplos do **[Código](./LOGIN_EXEMPLOS_CODIGO.md)** para demonstrações práticas

---

## 🔑 Conceitos-Chave

### JWT (JSON Web Token)
Token de autenticação usado para validar requisições. Contém informações do usuário codificadas.

### Access Token
Token JWT com validade curta (1 hora) usado para autenticar cada requisição.

### Refresh Token
Token com validade longa (30 dias) usado para gerar novos access tokens quando expiram.

### Supabase Auth
Serviço de autenticação que gera e valida os tokens JWT.

### Prisma
ORM usado para buscar dados adicionais do usuário no banco PostgreSQL.

### Repository Pattern
Padrão de arquitetura que separa a lógica de negócios da lógica de acesso a dados.

### Clean Architecture
Arquitetura em camadas (UI → BLoC → Use Case → Repository → DataSource).

---

## 🛠️ Stack Tecnológico

### Backend
- **Next.js 14** - Framework React/Node.js
- **TypeScript** - Linguagem tipada
- **Supabase Auth** - Autenticação JWT
- **Prisma** - ORM para PostgreSQL
- **PostgreSQL** - Banco de dados

### Frontend
- **Flutter 3.x** - Framework mobile
- **Dart** - Linguagem
- **Riverpod** - State management
- **Dio** - Cliente HTTP
- **Retrofit** - Gerador de API clients
- **json_serializable** - Serialização JSON

---

## 📊 Fluxo Resumido (10 segundos)

```
Usuário → Flutter envia email/senha → Backend valida no Supabase 
→ Backend busca dados no Prisma → Backend retorna user + tokens 
→ Flutter salva localmente → Usuário logado! 🎉
```

---

## ❓ FAQ Rápido

### Como faço para testar o login?
Veja: [Exemplos de Código - Seção Testes](./LOGIN_EXEMPLOS_CODIGO.md#-testes)

### O token expirou, e agora?
Veja: [Documentação Completa - Renovação de Token](./PROCESSO_LOGIN_BACKEND.md#-renovação-de-token-refresh-token)

### Como adiciono o token nas requisições?
Veja: [Exemplos de Código - Auth Interceptor](./LOGIN_EXEMPLOS_CODIGO.md#4-auth-interceptor-adiciona-token-automaticamente)

### Onde os tokens são salvos?
Veja: [Exemplos de Código - Local Storage](./LOGIN_EXEMPLOS_CODIGO.md#5-local-storage-sharedpreferences)

### Como debugar erros de login?
Veja: [Resumo Executivo - Debugging](./LOGIN_RESUMO_EXECUTIVO.md#-debugging-rápido)

### Qual a diferença entre login e registro?
Veja: [Diagramas - Comparação](./DIAGRAMA_FLUXO_LOGIN.md#-comparação-login-vs-registro)

---

## 🔗 Links Externos Úteis

### Documentação Oficial:
- [Supabase Auth](https://supabase.com/docs/guides/auth)
- [Next.js API Routes](https://nextjs.org/docs/api-routes/introduction)
- [Flutter HTTP Networking](https://docs.flutter.dev/data-and-backend/networking)
- [Riverpod](https://riverpod.dev)
- [Prisma](https://www.prisma.io/docs)

### Ferramentas:
- [JWT.io - Decodificador](https://jwt.io)
- [Postman - API Testing](https://www.postman.com)
- [Mermaid Live Editor](https://mermaid.live)

---

## 📞 Suporte

### Encontrou um erro?
1. Verifique a seção de **[Debugging](./LOGIN_RESUMO_EXECUTIVO.md#-debugging-rápido)**
2. Consulte os **[Diagramas de Estado](./DIAGRAMA_FLUXO_LOGIN.md#-estados-do-login)**
3. Revise os **[Códigos HTTP](./LOGIN_RESUMO_EXECUTIVO.md#-códigos-http)**

### Precisa adicionar funcionalidade?
1. Estude a **[Arquitetura](./DIAGRAMA_FLUXO_LOGIN.md#-arquitetura-do-sistema)**
2. Use os **[Exemplos de Código](./LOGIN_EXEMPLOS_CODIGO.md)** como base
3. Siga os padrões da **[Documentação Completa](./PROCESSO_LOGIN_BACKEND.md)**

---

## 📝 Estrutura de Arquivos

```
mealtime_app/
├── DOCUMENTACAO_LOGIN_INDEX.md          ← Você está aqui!
├── PROCESSO_LOGIN_BACKEND.md            ← Documentação técnica completa
├── DIAGRAMA_FLUXO_LOGIN.md              ← Diagramas visuais
├── LOGIN_RESUMO_EXECUTIVO.md            ← Guia rápido
└── LOGIN_EXEMPLOS_CODIGO.md             ← Código-fonte pronto
```

---

## ✨ Recursos Adicionais

### Arquivos do Projeto (Código Real):

#### Backend:
- `app/api/auth/mobile/route.ts` - Endpoint de login
- `app/api/auth/mobile/register/route.ts` - Endpoint de registro

#### Frontend:
- `lib/features/auth/data/repositories/auth_repository_impl.dart` - Repository
- `lib/features/auth/data/datasources/auth_remote_datasource.dart` - Data source
- `lib/services/api/auth_api_service.dart` - API service
- `lib/core/network/auth_interceptor.dart` - Interceptor
- `lib/features/auth/presentation/pages/login_page.dart` - Tela de login

---

## 🎯 Checklist de Implementação

Use este checklist para garantir que tudo está funcionando:

### Backend:
- [ ] Endpoint POST /api/auth/mobile implementado
- [ ] Integração com Supabase Auth funcionando
- [ ] Queries Prisma retornando dados completos
- [ ] Household e members sendo incluídos na resposta
- [ ] Tokens (access e refresh) sendo retornados
- [ ] Tratamento de erros (400, 401, 404, 500)
- [ ] Logging de operações configurado

### Frontend:
- [ ] Tela de login criada
- [ ] AuthApiService configurado com Retrofit
- [ ] AuthRepository implementado
- [ ] AuthInterceptor adicionando tokens automaticamente
- [ ] Tokens sendo salvos no SharedPreferences
- [ ] Sistema de refresh token funcionando
- [ ] Tratamento de erros na UI
- [ ] Navegação após login bem-sucedida
- [ ] Guard de rotas protegendo páginas autenticadas

### Testes:
- [ ] Testes unitários do repository
- [ ] Testes de integração do endpoint
- [ ] Teste manual com Postman/Insomnia
- [ ] Teste no dispositivo real

---

## 📅 Histórico de Atualizações

| Data | Versão | Mudanças |
|------|---------|----------|
| Jan 2025 | 1.0 | Documentação inicial completa |

---

## 👥 Contribuidores

- **Backend:** TypeScript/Next.js com Supabase Auth + Prisma
- **Frontend:** Flutter/Dart com Clean Architecture
- **Documentação:** Gerada via GitHub MCP

---

## 📄 Licença

Este projeto e sua documentação fazem parte do aplicativo Mealtime.

---

**🎉 Pronto para começar? Escolha um dos documentos acima e bons estudos!**

---

<div align="center">

### Navegação Rápida

**[📘 Documentação Completa](./PROCESSO_LOGIN_BACKEND.md)** | 
**[📊 Diagramas](./DIAGRAMA_FLUXO_LOGIN.md)** | 
**[⚡ Resumo](./LOGIN_RESUMO_EXECUTIVO.md)** | 
**[💻 Código](./LOGIN_EXEMPLOS_CODIGO.md)**

</div>






