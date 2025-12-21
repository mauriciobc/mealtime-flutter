# 📱 Como Conectar Dispositivo Android via Wi-Fi com ADB

> **Guia Completo para Depuração WiFi**  
> Aprenda a conectar seu dispositivo Android ao computador usando WiFi, sem precisar de cabo USB!

## 🎯 O que é ADB e Por Que Usar WiFi?

**ADB (Android Debug Bridge)** é uma ferramenta de linha de comando que permite comunicar com dispositivos Android. Normalmente, você conecta via USB, mas usar WiFi oferece:

- ✅ **Liberdade de movimento** - Sem cabos
- ✅ **Múltiplos dispositivos** - Conecte vários ao mesmo tempo
- ✅ **Desenvolvimento confortável** - Mantenha o dispositivo carregando separadamente

## 🔧 Pré-requisitos no Dispositivo

### 1. Habilitar Opções de Desenvolvedor
1. Vá em **Configurações** → **Sobre o telefone**
2. Toque **7 vezes** em **Número da versão** (ou **Versão do MIUI**)
   - Você verá uma mensagem dizendo "Você agora é um desenvolvedor!"
3. Volte para **Configurações** → **Configurações adicionais** → **Opções do desenvolvedor**

> 💡 **Dica:** Se não encontrar "Configurações adicionais", procure diretamente por "Opções do desenvolvedor" no campo de busca.

### 2. Configurar Depuração Wi-Fi
Nas **Opções do desenvolvedor**, ative:

1. ✅ **Depuração USB** (obrigatório, mesmo para WiFi)
2. ✅ **Depuração sem fio** ou **Wireless debugging** (Android 11+)
   - Esta opção permite a depuração WiFi nativa
3. ⚠️ **Revogar autorizações de depuração USB** (opcional, para segurança)
   - Use isso se precisar reiniciar as autorizações

### 3. Conectar o Dispositivo

### 📍 Descobrir o IP do Seu Dispositivo

Antes de conectar, você precisa saber o IP do dispositivo:

**No Android:**
1. Vá em **Configurações** → **Sobre o telefone** → **Status** → **Endereço IP**
2. Ou: **Configurações** → **Wi‑Fi** → Toque no Wi‑Fi conectado → Veja o IP

O IP geralmente é algo como `192.168.x.x` ou `10.0.x.x`

---

## 🔌 Métodos de Conexão

### 📱 Método 1: Android 11+ - Depuração Sem Fio Nativa (Recomendado)

Este é o método mais moderno e seguro, disponível no Android 11+:

1. **No dispositivo Android:**
   - Ative **Depuração sem fio** nas opções do desenvolvedor
   - Toque em **Depuração sem fio** para abrir as configurações
   - Você verá algo como:
     - **IP e porta para emparelhamento:** `192.168.68.106:43563`
     - **IP e porta para conexão:** `192.168.68.106:43125`

2. **No computador, emparelhe primeiro (uma vez só):**
   ```bash
   adb pair 192.168.68.106:43563
   ```
   - Será pedido um código de 6 dígitos
   - Digite o código mostrado na tela do dispositivo
   - Você verá: `Successfully paired to 192.168.68.106:43563`

3. **Depois, conecte usando a porta de conexão:**
   ```bash
   adb connect 192.168.68.106:43125
   ```

> ⚠️ **Nota:** As portas mudam a cada reinicialização. Você precisará emparelhar novamente se reiniciar o dispositivo.

---

### 🔌 Método 2: Via USB Primeiro (Compatível com Todos os Android)

Este método funciona em qualquer versão do Android, mas requer USB na primeira vez:

1. **Primeira conexão (via USB):**
   ```bash
   # Conecte o dispositivo via USB
   adb devices  # Verifique se detecta o dispositivo
   
   # Se aparecer "unauthorized", autorize no dispositivo primeiro
   
   # Ativa modo TCP/IP na porta 5555
   adb tcpip 5555
   ```
   
   Você verá: `restarting in TCP mode port: 5555`

2. **Desconecte o USB e conecte via Wi-Fi:**
   ```bash
   # Use o IP do seu dispositivo (exemplo: 192.168.68.106)
   adb connect 192.168.68.106:5555
   ```

> 💡 **Dica:** A porta 5555 é a padrão do ADB. Você pode usar outra porta se preferir (ex: 5556, 5557, etc).

---

### 🔧 Método 3: Se Já Estiver Configurado com Porta Customizada

Se você já configurou uma porta específica anteriormente:

```bash
adb connect 192.168.68.106:38035
```

> ⚠️ **Atenção:** Substitua `192.168.68.106` pelo IP do seu dispositivo e `38035` pela porta configurada.

## ✅ Verificar Conexão

Após tentar conectar, **sempre verifique** se funcionou:

```bash
adb devices
```

**✅ Sucesso:** Você verá algo como:
```
List of devices attached
192.168.68.106:38035    device
```

**❌ Problemas comuns:**

- `unauthorized` - Precisa autorizar no dispositivo
- `offline` - Dispositivo não está respondendo
- `no devices/emulators found` - Não conseguiu conectar

---

## 🔐 Autorizar o Computador

Na primeira conexão, aparecerá um diálogo no dispositivo:

**"Autorizar depuração USB?"**
- Mostra uma **chave RSA** para identificar seu computador
- Marque **"Sempre permitir deste computador"** para evitar prompts futuros
- Toque em **"Permitir"** ou **"OK"**

> 🔒 **Segurança:** Apenas autorize computadores que você confia. A chave RSA garante que ninguém possa se conectar sem autorização.

## 🚀 Usar com Flutter

Após conectar via ADB, o Flutter detectará automaticamente o dispositivo:

```bash
# Ver todos os dispositivos disponíveis
flutter devices
```

Você verá algo como:
```
2 connected devices:

Redmi Note 8 (mobile) • 192.168.68.106:38035 • android-arm64  • Android 11 (API 30)
Chrome (web)          • chrome                • web-javascript • Google Chrome 120.0.0.0
```

**Para executar o app:**

```bash
# Especificar o dispositivo explicitamente
flutter run -d 192.168.68.106:38035

# Ou simplesmente (Flutter escolhe automaticamente)
flutter run
```

**Hot Reload funciona normalmente!** Pressione `r` para recarregar, `R` para reiniciar.

## 🔥 Configurar Firewall (Linux)

Se você usa Linux com `firewalld` e está tendo problemas de conexão, pode ser o firewall bloqueando. Veja o guia completo em [`FIREWALL_ADB_SETUP.md`](./FIREWALL_ADB_SETUP.md).

**Resumo rápido:**

```bash
# Permitir porta do ADB (5555)
sudo firewall-cmd --add-port=5555/tcp --permanent

# Ou se usar porta customizada (ex: 43125)
sudo firewall-cmd --add-port=43125/tcp --permanent

# Recarregar firewall
sudo firewall-cmd --reload
```

---

## 🐛 Troubleshooting - Resolvendo Problemas

### ❌ Erro: "failed to connect"

**Possíveis causas:**
1. **Dispositivo e computador não estão na mesma rede Wi-Fi**
   - ✅ Verifique que ambos estão conectados à mesma rede
   - ✅ Teste: Faça ping no IP do dispositivo: `ping 192.168.68.106`

2. **Opções de desenvolvedor não estão ativadas**
   - ✅ Verifique se "Depuração USB" está ativa
   - ✅ Verifique se "Depuração sem fio" está ativa (Android 11+)

3. **ADB server precisa ser reiniciado**
   ```bash
   adb kill-server && adb start-server
   ```

4. **Diálogo de autorização pendente no dispositivo**
   - ✅ Olhe a tela do dispositivo, pode ter um diálogo esperando autorização

---

### ❌ Erro: "Connection refused"

**O que significa:** O computador não consegue se conectar à porta do dispositivo.

**Soluções:**
1. ✅ Verifique se o IP e porta estão corretos
   ```bash
   # Teste a conexão manualmente
   telnet 192.168.68.106 5555
   # ou
   nc -zv 192.168.68.106 5555
   ```

2. ✅ Firewall bloqueando (veja seção acima)
   - No Linux: configure o firewalld
   - No Windows/Mac: verifique se o firewall não está bloqueando

3. ✅ Tente usar a porta padrão 5555 primeiro
   ```bash
   # Conecte via USB e ative TCP/IP
   adb tcpip 5555
   ```

4. ✅ Rede pode estar bloqueando conexões entre dispositivos
   - Alguns roteadores têm "isolamento de cliente" que bloqueia isso
   - Verifique nas configurações do roteador

---

### ❌ Dispositivo aparece como "unauthorized"

**O que fazer:**
1. ✅ No dispositivo, aparecerá um diálogo pedindo autorização
   - Procure na tela do dispositivo
   - Pode estar na área de notificações

2. ✅ Toque em **"Permitir"** ou **"Autorizar"**

3. ✅ Marque **"Sempre permitir deste computador"** para evitar futuros prompts

4. ✅ Se não aparecer o diálogo, tente:
   ```bash
   # Revogar autorizações no dispositivo (nas opções do desenvolvedor)
   # Depois tente conectar novamente
   adb kill-server && adb start-server
   adb connect 192.168.68.106:5555
   ```

---

### ❌ Porta customizada não funciona

**Soluções:**
1. ✅ Tente usar a porta padrão 5555
   ```bash
   adb tcpip 5555  # Via USB primeiro
   adb connect 192.168.68.106:5555  # Via WiFi
   ```

2. ✅ Verifique no dispositivo qual porta está configurada
   - Android 11+: Veja em "Depuração sem fio"
   - Android antigo: A porta padrão após `adb tcpip` é 5555

3. ✅ Para Android 11+, use o método nativo de **Depuração sem fio**
   - Mais confiável e seguro
   - Veja "Método 1" acima

---

### ❌ "cannot connect to 192.168.68.106:5555: Connection timed out"

**Causa:** O dispositivo não está escutando na porta ou o IP mudou.

**Soluções:**
1. ✅ Verifique se o IP do dispositivo mudou
   - IPs podem mudar se o dispositivo se reconectar ao WiFi
   - Verifique o IP atual no dispositivo

2. ✅ Reinicie o modo TCP/IP (precisa USB novamente):
   ```bash
   adb tcpip 5555  # Conecte via USB primeiro
   ```

3. ✅ No Android 11+, use o emparelhamento nativo:
   ```bash
   adb pair <IP>:<PORTA_EMPARELHAMENTO>
   adb connect <IP>:<PORTA_CONEXAO>
   ```

---

### ❌ "no devices/emulators found"

**Soluções:**
1. ✅ Verifique se conseguiu conectar:
   ```bash
   adb devices
   ```

2. ✅ Tente desconectar e reconectar:
   ```bash
   adb disconnect 192.168.68.106:5555
   adb connect 192.168.68.106:5555
   ```

3. ✅ Reinicie o servidor ADB:
   ```bash
   adb kill-server
   adb start-server
   adb connect 192.168.68.106:5555
   ```

## 📝 Notas Importantes e Boas Práticas

### 🔒 Segurança
- **Mesma rede Wi-Fi**: Dispositivo e computador devem estar na mesma rede local
- **Autorização única**: Na primeira conexão, você autoriza o computador uma vez
- **Chave RSA**: O dispositivo usa uma chave criptográfica para garantir segurança
- **Não use em redes públicas**: Use apenas em redes Wi-Fi confiáveis (casa, trabalho)

### ⚡ Performance
- **Velocidade**: WiFi geralmente é mais lento que USB, mas suficiente para desenvolvimento
- **Latência**: Pode haver um pequeno delay, mas não afeta o desenvolvimento normal
- **Hot Reload**: Funciona normalmente, pode ser um pouco mais lento que USB

### 🔄 Manutenção
- **IP dinâmico**: Se o IP do dispositivo mudar, você precisará reconectar
- **Portas temporárias**: No Android 11+ nativo, as portas mudam ao reiniciar
- **Sessão persistente**: A conexão se mantém mesmo se o dispositivo dormir (com WiFi sempre ativa)

### 💡 Dicas Pro
- **Script de conexão**: Crie um script para conectar rapidamente
  ```bash
  #!/bin/bash
  # Salve como connect-device.sh
  adb connect 192.168.68.106:5555
  adb devices
  ```
- **Múltiplos dispositivos**: Você pode conectar vários dispositivos simultaneamente
- **Alias ADB**: Configure um alias para comandos comuns:
  ```bash
  alias adbc='adb connect 192.168.68.106:5555'
  alias adbd='adb devices'
  ```

---

## 📚 Referências e Links Úteis

- [Documentação Oficial do ADB](https://developer.android.com/tools/adb)
- [Depuração WiFi no Android 11+](https://developer.android.com/tools/adb#wireless-android11)
- [Guia de Configuração de Firewall](./FIREWALL_ADB_SETUP.md) para Linux

---

## ✅ Checklist Rápido

Antes de desistir, verifique:

- [ ] Dispositivo e computador na mesma rede Wi-Fi?
- [ ] Opções de desenvolvedor ativadas?
- [ ] Depuração USB ativada?
- [ ] Depuração sem fio ativada (Android 11+)?
- [ ] IP do dispositivo verificado?
- [ ] Porta correta sendo usada?
- [ ] Diálogo de autorização foi aceito?
- [ ] Firewall não está bloqueando?
- [ ] ADB server foi reiniciado?

**Se tudo isso está OK e ainda não funciona, tente conectar via USB primeiro para garantir que o ADB está funcionando.**

