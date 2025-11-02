# 🔄 Diagrama de Fluxo - Login no Mealtime

## 📊 Fluxo Completo de Autenticação

```mermaid
sequenceDiagram
    participant U as 👤 Usuário
    participant F as 📱 Flutter App
    participant LD as 💾 LocalDataSource
    participant B as 🌐 Backend API
    participant SA as 🔐 Supabase Auth
    participant DB as 🗄️ Prisma/PostgreSQL

    U->>F: Digite email e senha
    F->>F: Valida campos não vazios
    
    Note over F,B: POST /api/auth/mobile
    F->>B: { email, password }
    
    Note over B: Validação de entrada
    B->>B: Verifica campos obrigatórios
    
    Note over B,SA: Autenticação
    B->>SA: signInWithPassword()
    SA->>SA: Verifica email/senha
    SA->>SA: Gera JWT tokens
    SA-->>B: { user, session, tokens }
    
    alt Credenciais inválidas
        B-->>F: 401: Credenciais inválidas
        F-->>U: ❌ Mostra erro
    else Credenciais válidas
        Note over B,DB: Buscar dados completos
        B->>DB: findUnique(auth_id)
        B->>DB: include household & members
        DB-->>B: User + Household + Members
        
        alt Usuário não existe no Prisma
            B-->>F: 404: Usuário não encontrado
            F-->>U: ❌ Mostra erro
        else Usuário encontrado
            Note over B: Preparar resposta
            B->>B: Monta objeto userData
            B->>B: Inclui household e members
            
            B-->>F: 200: { success, user, tokens }
            
            Note over F: Processar resposta
            F->>F: Valida AuthResponse
            F->>F: Converte JSON → Dart
            
            Note over F,LD: Armazenamento local
            F->>LD: saveTokens(access, refresh)
            F->>LD: saveUser(userModel)
            LD-->>F: ✅ Dados salvos
            
            F->>F: Atualiza estado (Riverpod)
            F-->>U: ✅ Navega para Home
            
            Note over U: Login bem-sucedido! 🎉
        end
    end
```

## 🔑 Uso do Token em Requisições Subsequentes

```mermaid
sequenceDiagram
    participant F as 📱 Flutter App
    participant I as 🔧 AuthInterceptor
    participant LD as 💾 LocalDataSource
    participant B as 🌐 Backend API

    F->>F: Requisição qualquer (ex: GET /cats)
    F->>I: onRequest()
    I->>LD: getAccessToken()
    LD-->>I: access_token
    I->>I: headers['Authorization'] = 'Bearer token'
    I->>B: Request com Authorization header
    
    alt Token válido
        B-->>I: 200: Dados solicitados
        I-->>F: Response
        F-->>F: Processa dados
    else Token expirado
        B-->>I: 401: Token expirado
        I->>I: Detecta erro 401
        I->>LD: getRefreshToken()
        LD-->>I: refresh_token
        
        Note over I,B: PUT /api/auth/mobile
        I->>B: { refresh_token }
        B-->>I: { new_access_token, new_refresh_token }
        
        I->>LD: saveTokens(new_access, new_refresh)
        I->>B: Repete requisição original com novo token
        B-->>I: 200: Dados solicitados
        I-->>F: Response
    end
```

## 🏗️ Arquitetura do Sistema

```mermaid
graph TB
    subgraph "📱 Flutter App"
        UI[UI Layer<br/>LoginPage]
        BLoC[BLoC/Riverpod<br/>AuthNotifier]
        Repo[Repository Layer<br/>AuthRepositoryImpl]
        DS[DataSource Layer<br/>RemoteDataSource]
        API[API Layer<br/>Retrofit + Dio]
    end
    
    subgraph "🌐 Backend (Next.js)"
        Route[API Route<br/>/auth/mobile/route.ts]
        SClient[Supabase Client<br/>createClient]
        PClient[Prisma Client<br/>prisma]
    end
    
    subgraph "🔐 Supabase"
        Auth[Supabase Auth<br/>JWT Generation]
    end
    
    subgraph "🗄️ Database"
        PG[(PostgreSQL<br/>users, households)]
    end
    
    UI -->|Email/Password| BLoC
    BLoC -->|Call login| Repo
    Repo -->|Transform| DS
    DS -->|HTTP POST| API
    API -->|Request| Route
    
    Route -->|signInWithPassword| SClient
    SClient -->|Authenticate| Auth
    Auth -->|Tokens| SClient
    SClient -->|Success| Route
    
    Route -->|findUnique| PClient
    PClient -->|Query| PG
    PG -->|User Data| PClient
    PClient -->|Result| Route
    
    Route -->|JSON Response| API
    API -->|AuthResponse| DS
    DS -->|Model| Repo
    Repo -->|Entity| BLoC
    BLoC -->|Update State| UI
```

## 📦 Estrutura de Dados

```mermaid
classDiagram
    class LoginRequest {
        +String email
        +String password
        +toJson() Map
    }
    
    class AuthResponse {
        +bool success
        +String accessToken
        +String refreshToken
        +int expiresIn
        +String tokenType
        +UserModel user
        +String error
        +isSuccess() bool
        +hasError() bool
    }
    
    class UserModel {
        +String id
        +String authId
        +String fullName
        +String email
        +String householdId
        +HouseholdModel household
        +DateTime createdAt
        +toEntity() User
    }
    
    class HouseholdModel {
        +String id
        +String name
        +List~MemberModel~ members
    }
    
    class MemberModel {
        +String id
        +String name
        +String email
        +String role
    }
    
    LoginRequest --> AuthResponse : Backend processa
    AuthResponse --> UserModel : Contém
    UserModel --> HouseholdModel : Pode ter
    HouseholdModel --> MemberModel : Lista de
```

## 🔄 Estados do Login

```mermaid
stateDiagram-v2
    [*] --> Idle: App iniciado
    
    Idle --> Loading: Usuário clica "Entrar"
    Loading --> CheckingCredentials: Envia requisição
    
    CheckingCredentials --> AuthenticatingSupabase: Validação OK
    CheckingCredentials --> Error: Campos vazios
    
    AuthenticatingSupabase --> FetchingUserData: Supabase OK
    AuthenticatingSupabase --> Error: Credenciais inválidas
    
    FetchingUserData --> SavingLocally: Dados recebidos
    FetchingUserData --> Error: Usuário não existe
    
    SavingLocally --> Success: Tokens salvos
    SavingLocally --> Error: Falha ao salvar
    
    Success --> [*]: Navega para Home
    Error --> Idle: Tenta novamente
```

## 🔐 Estrutura do JWT Token

```mermaid
graph LR
    A[JWT Token] --> B[Header]
    A --> C[Payload]
    A --> D[Signature]
    
    B --> B1[alg: HS256]
    B --> B2[typ: JWT]
    
    C --> C1[sub: user_id]
    C --> C2[email: user@example.com]
    C --> C3[iat: issued_at]
    C --> C4[exp: expires_at]
    
    D --> D1[HMACSHA256<br/>header + payload + secret]
    
    style A fill:#2ecc71
    style B fill:#3498db
    style C fill:#e74c3c
    style D fill:#f39c12
```

## ⏱️ Ciclo de Vida do Token

```mermaid
timeline
    title Ciclo de Vida do Access Token (1 hora)
    section Login
        T+0min : Login bem-sucedido<br/>Token gerado
        T+5min : Requisições normais<br/>Token válido
        T+30min : Requisições normais<br/>Token ainda válido
    section Pré-expiração
        T+55min : Requisições normais<br/>Token próximo de expirar
    section Expiração
        T+60min : Token expira<br/>Requisição falha 401
        T+60.5min : Refresh automático<br/>Novo token gerado
        T+61min : Requisição repetida<br/>Sucesso com novo token
    section Novo Ciclo
        T+120min : Novo token expira<br/>Processo se repete
```

## 🌊 Fluxo de Dados no Flutter

```mermaid
graph TD
    A[UI: LoginPage] -->|User Input| B[BLoC: AuthNotifier]
    B -->|loginWithEmailAndPassword| C[UseCase: Login]
    C -->|execute| D[Repository: AuthRepository]
    D -->|login| E[DataSource: RemoteDataSource]
    E -->|HTTP POST| F[API Service: Retrofit]
    F -->|Network Request| G[Backend]
    
    G -->|JSON Response| F
    F -->|AuthResponse| E
    E -->|Model| D
    D -->|Either Success/Failure| C
    C -->|Result| B
    B -->|State Update| A
    
    style A fill:#e3f2fd
    style B fill:#bbdefb
    style C fill:#90caf9
    style D fill:#64b5f6
    style E fill:#42a5f5
    style F fill:#2196f3
    style G fill:#1976d2
```

## 📊 Comparação: Login vs Registro

```mermaid
graph LR
    subgraph Login
        L1[POST /auth/mobile] --> L2[Supabase Auth]
        L2 --> L3[Busca no Prisma]
        L3 --> L4[Retorna User + Tokens]
    end
    
    subgraph Registro
        R1[POST /auth/mobile/register] --> R2[Cria no Supabase]
        R2 --> R3[Cria Household]
        R3 --> R4[Cria User no Prisma]
        R4 --> R5[Cria HouseholdMember]
        R5 --> R6[Retorna User + Tokens]
    end
    
    style Login fill:#a5d6a7
    style Registro fill:#fff59d
```

---

## 📝 Legenda

| Símbolo | Significado |
|---------|-------------|
| 👤 | Usuário final |
| 📱 | Aplicativo Flutter |
| 💾 | Armazenamento local |
| 🌐 | Backend/API |
| 🔐 | Supabase Auth |
| 🗄️ | Banco de dados |
| ✅ | Sucesso |
| ❌ | Erro |
| 🎉 | Operação concluída |

---

## 🔗 Links Úteis

- [Visualizar diagramas Mermaid online](https://mermaid.live)
- [Documentação Mermaid](https://mermaid.js.org)
- [Processo de Login completo](./PROCESSO_LOGIN_BACKEND.md)

---

**Última atualização:** Janeiro 2025






