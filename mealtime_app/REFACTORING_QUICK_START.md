# ⚡ Quick Start: Refatoração Households

**Tempo:** 3-4 horas | **Dificuldade:** Média | **Impacto:** Alto

---

## 🎯 Objetivo

Tornar o código 100% compatível com a API de Households

---

## ⚠️ Antes de Começar

```bash
# 1. Criar branch
git checkout -b refactor/households-api-compatibility

# 2. Fazer backup
mkdir -p backup/households_$(date +%Y%m%d)

# 3. Salvar estado atual
flutter test > backup/tests_before.txt
```

---

## 🚀 Passos Rápidos

### 1️⃣ Criar Novo Modelo (20 min)

Criar: `lib/features/homes/data/models/household_model.dart`

<details>
<summary>Ver código completo (clique para expandir)</summary>

```dart
// Cole o código do HouseholdModel aqui
// (Consulte REFACTORING_PLAN_HOUSEHOLDS.md, Passo 2.1)
```
</details>

```bash
# Gerar código
flutter pub run build_runner build --delete-conflicting-outputs
```

---

### 2️⃣ Atualizar API (15 min)

**api_constants.dart:**
```dart
static const String households = '/households';  // não /homes
```

**homes_api_service.dart:**
```dart
@GET('/households')  // mudou
@POST('/households')  // mudou
Future<ApiResponse<HouseholdModel>> createHousehold({  // mudou tipo
  @Field('name') required String name,
  @Field('description') String? description,
  // REMOVER: @Field('address')
});
```

```bash
# Regenerar
flutter pub run build_runner build --delete-conflicting-outputs
```

---

### 3️⃣ Atualizar DataSource (10 min)

**homes_remote_datasource.dart:**
- Mudar `HomeModel` → `HouseholdModel`
- Remover parâmetro `address`
- Mudar `getHomes()` → `getHouseholds()`

---

### 4️⃣ Atualizar Repository (10 min)

**homes_repository_impl.dart:**
- Remover parâmetro `address`
- Tipos já mudam automaticamente

---

### 5️⃣ Atualizar UseCases (10 min)

**create_home.dart** e **update_home.dart:**
- Remover `address` de `Params`

---

### 6️⃣ Atualizar BLoC (15 min)

**homes_event.dart:**
- Remover `address` dos eventos

**homes_bloc.dart:**
- Atualizar chamadas aos UseCases

---

### 7️⃣ Atualizar UI (20 min)

**home_form.dart:**
- Remover campo de endereço
- Remover controller de endereço
- Atualizar `onSubmit`

---

### 8️⃣ Adicionar Header (15 min)

**auth_interceptor.dart:**
```dart
@override
void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
  final token = await tokenManager.getToken();
  if (token != null) {
    options.headers['Authorization'] = 'Bearer $token';
  }
  
  // ✅ NOVO
  final userId = await tokenManager.getUserId();
  if (userId != null) {
    options.headers['x-user-id'] = userId;
  }
  
  handler.next(options);
}
```

**token_manager.dart:**
```dart
Future<String?> getUserId() async {
  final token = await getToken();
  if (token == null) return null;
  
  final parts = token.split('.');
  final payload = base64.decode(base64.normalize(parts[1]));
  final decoded = json.decode(utf8.decode(payload));
  return decoded['sub'];
}
```

---

### 9️⃣ Testar (20 min)

```bash
# Compilar
flutter pub get
flutter analyze

# Rodar app
flutter run

# Testar manualmente:
# - Criar household
# - Listar households
# - Atualizar household
# - Deletar household
```

---

## ✅ Checklist Final

- [ ] App compila sem erros
- [ ] Criar household funciona (201)
- [ ] Listar households funciona (200)
- [ ] Campo endereço removido da UI
- [ ] Header `x-user-id` sendo enviado

---

## 🆘 Se Algo Der Errado

```bash
# Reverter tudo
git checkout main
git branch -D refactor/households-api-compatibility

# Ou restaurar backup
cp backup/households_*/home_model.dart lib/features/homes/data/models/
```

---

## 📚 Documentação Completa

Para detalhes completos, ver:
**`REFACTORING_PLAN_HOUSEHOLDS.md`**

---

## 🎉 Resultado Final

✅ Código 100% compatível  
✅ Criar household funciona  
✅ Sem erros 404  
✅ Headers corretos  
✅ UI atualizada  

**Pronto para produção!** 🚀

