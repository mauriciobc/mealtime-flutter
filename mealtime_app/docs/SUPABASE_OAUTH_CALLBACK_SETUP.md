# Configuração do callback OAuth (Redirect URL) no Supabase

## Limitação do Supabase MCP

O **Supabase MCP** (servidor `user-supabase`) não expõe ferramenta para configurar Redirect URLs ou opções de Auth. As ferramentas disponíveis são: `execute_sql`, `apply_migration`, `list_tables`, `get_project_url`, `get_publishable_keys`, edge functions, branches, etc. A lista de **Redirect URLs** e a **URL Configuration** são definidas apenas pelo **Dashboard** do Supabase.

## Como configurar o callback no Dashboard

No Supabase, em **Authentication** → **URL Configuration**, a seção **Redirect URLs** lista as *"URLs that auth providers are permitted to redirect to post authentication"*. Wildcards são permitidos (ex.: `https://*.domain.com`). Para o app móvel MealTime use deep link URIs.

1. Abra a página de **URL Configuration** do seu projeto:
   - **Link direto (projeto MealTime):**  
     [https://supabase.com/dashboard/project/zzvmyzyszsqptgyqwqwt/auth/url-configuration](https://supabase.com/dashboard/project/zzvmyzyszsqptgyqwqwt/auth/url-configuration)
   - Ou: Dashboard → **Authentication** → **URL Configuration**.

2. Em **Redirect URLs**, inclua exatamente estas URLs (uma por linha):
   ```
   io.mealtime.app://login-callback/
   io.mealtime.app://login-callback
   ```

3. Salve as alterações.

O app usa `SupabaseConfig.deepLinkUrl` (`io.mealtime.app://login-callback/`). Incluir a variante sem barra final garante compatibilidade com qualquer normalização que o Supabase faça.

## Google OAuth

Para login com Google, além das Redirect URLs acima:

- Em **Authentication** → **Providers** → **Google**: ative o provider e preencha Client ID e Client Secret (Google Cloud Console).
- No **Google Cloud Console**, em “URIs de redirecionamento autorizados” da credencial OAuth 2.0, adicione a URL de callback que o Supabase mostra nessa tela do provider Google, por exemplo:
  `https://zzvmyzyszsqptgyqwqwt.supabase.co/auth/v1/callback`

**Sim, é obrigatório configurar no Google também.** O Google é provedor externo: ele só redireciona para URIs que você adicionar em **Authorized redirect URIs** na credencial OAuth 2.0 (tipo Web application). A URL a adicionar é a do callback do Supabase (a mesma acima). Depois, no Supabase em **Authentication** → **Providers** → **Google**, ative o provider e cole o Client ID e Client Secret gerados no Google Cloud.

## Conferência via MCP (opcional)

Para confirmar a URL do projeto (e montar o link do Dashboard manualmente se o ref mudar):

- Use a ferramenta **get_project_url** do MCP `user-supabase`. A URL retornada tem a forma `https://<project-ref>.supabase.co`. O `<project-ref>` é o que aparece em:
  `https://supabase.com/dashboard/project/<project-ref>/auth/url-configuration`
