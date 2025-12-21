# 🔥 Configuração do Firewall para ADB via Wi-Fi

## 📋 O que permitir no Firewall

Para conectar ao dispositivo Android via Wi-Fi usando ADB, você precisa permitir as seguintes conexões no `firewalld`:

### 1. **Porta do Dispositivo Remoto (43125)**
Permite conexões de **saída** para a porta onde o dispositivo Android está escutando.

```bash
sudo firewall-cmd --add-port=43125/tcp --permanent
```

### 2. **Porta do ADB Server (5037)**
Permite conexões na porta padrão do ADB server (opcional, geralmente já permitido).

```bash
sudo firewall-cmd --add-port=5037/tcp --permanent
```

### 3. **Porta Padrão ADB (5555) - Opcional**
Se você usar a porta padrão do ADB no futuro:

```bash
sudo firewall-cmd --add-port=5555/tcp --permanent
```

### 4. **Aplicar as Mudanças**
Após adicionar as regras, recarregue o firewall:

```bash
sudo firewall-cmd --reload
```

## 🚀 Script Completo (Copie e Cole)

Execute estes comandos em sequência:

```bash
# Adicionar porta do dispositivo (43125)
sudo firewall-cmd --add-port=43125/tcp --permanent

# Adicionar porta ADB server (5037) - se necessário
sudo firewall-cmd --add-port=5037/tcp --permanent

# Recarregar firewall
sudo firewall-cmd --reload

# Verificar regras aplicadas
firewall-cmd --list-ports
```

## 🔍 Verificar Configuração Atual

Para ver o que está permitido atualmente:

```bash
# Listar todas as portas permitidas
firewall-cmd --list-ports

# Listar todos os serviços permitidos
firewall-cmd --list-services

# Ver configuração completa
firewall-cmd --list-all
```

## 🎯 Método Alternativo: Permitir por IP Específico

Se você quiser ser mais específico e permitir apenas conexões para o IP do dispositivo:

```bash
# Criar uma rich rule para permitir conexões para o IP específico
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" destination address="192.168.68.106" port port="43125" protocol="tcp" accept'

# Recarregar
sudo firewall-cmd --reload
```

## 📝 Notas Importantes

1. **Conexões de Saída**: O firewall precisa permitir conexões de **saída** (outbound) do seu computador para o dispositivo. Por padrão, o firewalld geralmente permite conexões de saída, mas é bom verificar.

2. **Zona Ativa**: Certifique-se de que as regras estão sendo adicionadas à zona correta. Para verificar:
   ```bash
   firewall-cmd --get-active-zones
   ```

3. **Temporário vs Permanente**: Use `--permanent` para tornar as regras permanentes. Sem ele, as regras serão perdidas ao reiniciar o firewall.

4. **Remover Regras**: Se precisar remover uma regra depois:
   ```bash
   sudo firewall-cmd --remove-port=43125/tcp --permanent
   sudo firewall-cmd --reload
   ```

## ✅ Verificar se Funcionou

Após configurar o firewall, teste a conexão:

```bash
# Tentar conectar
adb connect 192.168.68.106:43125

# Verificar dispositivos conectados
adb devices
```

## 🐛 Troubleshooting

### Se ainda não conectar após permitir no firewall:

1. **Verificar se a porta está acessível**:
   ```bash
   telnet 192.168.68.106 43125
   # ou
   nc -zv 192.168.68.106 43125
   ```

2. **Verificar logs do firewall** (para ver se está bloqueando):
   ```bash
   sudo journalctl -u firewalld -f
   ```

3. **Verificar regras iptables** (backend do firewalld):
   ```bash
   sudo iptables -L -n -v | grep 43125
   ```

4. **Testar temporariamente desabilitando o firewall** (apenas para teste!):
   ```bash
   sudo firewall-cmd --state  # Ver se está ativo
   # Não desabilite em produção, apenas para diagnóstico
   ```

## 📚 Referências

- [Firewalld Documentation](https://firewalld.org/documentation/)
- [ADB Network Documentation](https://developer.android.com/tools/adb)

