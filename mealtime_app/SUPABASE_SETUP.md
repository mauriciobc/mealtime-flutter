# 🔧 Configuração do Supabase para MealTime

Este guia explica como configurar o Supabase para o projeto MealTime Flutter.

## 📋 Pré-requisitos

1. Conta no [Supabase](https://supabase.com)
2. Projeto Flutter configurado
3. Flutter SDK instalado

## 🚀 Passo a Passo

### 1. Criar Projeto no Supabase

1. Acesse [supabase.com](https://supabase.com)
2. Faça login na sua conta
3. Clique em "New Project"
4. Preencha os dados do projeto:
   - **Name**: MealTime
   - **Database Password**: (escolha uma senha forte)
   - **Region**: (escolha a região mais próxima)
5. Clique em "Create new project"
6. Aguarde a criação do projeto (pode levar alguns minutos)

### 2. Configurar Schema do Banco de Dados

1. No dashboard do Supabase, vá para **SQL Editor**
2. Clique em **New Query**
3. Cole o seguinte SQL e execute:

```sql
-- Criar tabela de perfis de usuário
CREATE TABLE profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE,
  username TEXT,
  website TEXT,
  avatar_url TEXT,
  full_name TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  PRIMARY KEY (id)
);

-- Habilitar RLS (Row Level Security)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Política para usuários verem apenas seu próprio perfil
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

-- Política para usuários atualizarem apenas seu próprio perfil
CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- Política para usuários inserirem apenas seu próprio perfil
CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Criar bucket para avatars
INSERT INTO storage.buckets (id, name, public) VALUES ('avatars', 'avatars', true);

-- Política para upload de avatars
CREATE POLICY "Users can upload own avatar" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Política para visualizar avatars
CREATE POLICY "Users can view own avatar" ON storage.objects
  FOR SELECT USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Política para deletar avatars
CREATE POLICY "Users can delete own avatar" ON storage.objects
  FOR DELETE USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);
```

### 3. Obter Credenciais da API

1. No dashboard do Supabase, vá para **Settings** > **API**
2. Copie as seguintes informações:
   - **Project URL**
   - **anon public** key (ou **publishable key** se disponível)

### 4. Configurar Deep Links

1. No dashboard do Supabase, vá para **Authentication** > **URL Configuration**
2. Adicione as seguintes URLs de redirecionamento:
   - `io.mealtime.app://login-callback/`
   - `io.mealtime.app://login-callback`

### 5. Configurar o Projeto Flutter

1. Abra o arquivo `lib/core/supabase/supabase_config.dart`
2. Substitua as seguintes linhas com suas credenciais:

```dart
static const String supabaseUrl = 'SUA_URL_DO_SUPABASE';
static const String supabaseAnonKey = 'SUA_CHAVE_PUBLICA_DO_SUPABASE';
```

### 6. Testar a Configuração

1. Execute o projeto:
   ```bash
   flutter run
   ```

2. Teste o fluxo de autenticação:
   - Tente fazer login com Magic Link
   - Verifique se o email é enviado
   - Teste o upload de avatar

## 🔐 Configurações de Segurança

### Row Level Security (RLS)
O projeto está configurado com RLS ativado, garantindo que:
- Usuários só podem ver seus próprios dados
- Apenas o proprietário pode atualizar seu perfil
- Upload de arquivos é restrito ao usuário logado

### Deep Links
Os deep links estão configurados para:
- **Android**: `io.mealtime.app://login-callback/`
- **iOS**: `io.mealtime.app://login-callback/`

## 📱 Funcionalidades Implementadas

- ✅ **Magic Link Authentication**: Login sem senha via email
- ✅ **User Registration**: Cadastro com email e senha
- ✅ **Profile Management**: Gerenciamento de perfil do usuário
- ✅ **Avatar Upload**: Upload de foto de perfil
- ✅ **Deep Links**: Redirecionamento automático após login
- ✅ **Row Level Security**: Segurança a nível de linha

## 🐛 Solução de Problemas

### Erro de Deep Link
- Verifique se as URLs de redirecionamento estão configuradas no Supabase
- Confirme se os deep links estão configurados nos arquivos Android/iOS

### Erro de Upload
- Verifique se o bucket 'avatars' foi criado
- Confirme se as políticas de storage estão ativas

### Erro de Autenticação
- Verifique se as credenciais da API estão corretas
- Confirme se o RLS está configurado corretamente

## 📚 Recursos Adicionais

- [Documentação do Supabase Flutter](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter)
- [Guia de Deep Links](https://supabase.com/docs/guides/auth/auth-deep-linking)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
