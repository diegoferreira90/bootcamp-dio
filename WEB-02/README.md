# WEB‑02 – Força Bruta em HTTP com Token Anti‑CSRF (DVWA nível Medium)

## 📌 Objetivo
Realizar um ataque de **força bruta** contra a página de login da aplicação web **DVWA** (IP `192.168.1.11`) no **nível de segurança Medium**, que exige a captura dinâmica de um **token anti‑CSRF** (`user_token`) a cada tentativa de login. Este cenário demonstra como um atacante pode contornar proteções CSRF básicas automatizando a extração do token antes de enviar as credenciais.

## 🔑 Diferença em relação ao WEB‑01
| Aspecto | WEB‑01 (Low) | WEB‑02 (Medium) |
|---------|-------------|-----------------|
| Token anti‑CSRF | Não exigido | Campo hidden `user_token` obrigatório no POST |
| Cookie de sessão | Enviado automaticamente | Deve ser capturado e reutilizado (`PHPSESSID`) |
| Complexidade | Comando Medusa direto | Requer script auxiliar para capturar token + cookie |

## 🛠️ Pré‑requisitos
- **Kali Linux** (IP `192.168.1.10`) com Medusa e cURL instalados.
- **Metasploitable 2** (IP `192.168.1.11`) rodando DVWA na porta 80.
- **DVWA Security Level** configurado como **Medium** (via interface web: `http://192.168.1.11/dvwa/security.php`).
- Wordlists (incluídas nesta pasta):
  - `users.txt` – lista de usuários (`msfadmin`, `admin`, `user`, `root`).
  - `pass_small.txt` – lista de senhas (`password`, `123456`, `msfadmin`, `qwerty`, `Welcome123`, `admin`).

## 🧩 Como funciona o Token Anti‑CSRF

Quando a DVWA está no nível **Medium**, o formulário de login inclui um campo oculto:

```html
<input type="hidden" name="user_token" value="a1b2c3d4e5f6...">
```

Esse token é gerado pelo servidor **a cada carregamento da página** e deve ser enviado junto com `username` e `password` no POST. Se o token estiver ausente ou inválido, o servidor rejeita a requisição — mesmo que as credenciais estejam corretas.

Para automatizar o ataque, precisamos:
1. **Fazer um GET** na página de login para obter o cookie `PHPSESSID` e o valor do `user_token`.
2. **Enviar o POST** com `username`, `password` e `user_token` usando o mesmo cookie de sessão.
3. **Repetir** o processo para cada combinação de credenciais (pois o token muda a cada requisição).

## 📂 Arquivos desta pasta

| Arquivo | Descrição |
|---------|-----------|
| `dvwa_token.sh` | Script que captura o cookie de sessão e extrai o `user_token` do HTML |
| `run_web02.sh` | Script principal que executa o ataque em loop, renovando o token a cada iteração |
| `users.txt` | Wordlist de usuários |
| `pass_small.txt` | Wordlist de senhas |
| `web02.log` | Log de saída do Medusa (gerado após a execução) |
| `image.png` | Captura de tela dos resultados (adicionar após execução) |

## 🚀 Passo a passo para execução

### 1. Configurar o nível de segurança da DVWA

1. Acesse `http://192.168.1.11/dvwa/` no navegador.
2. Faça login com `admin:password`.
3. Vá em **DVWA Security** → altere para **Medium** → clique **Submit**.

### 2. Copiar os arquivos para o Kali

Copie toda a pasta `WEB-02` para o Kali (ex.: `/home/periciakali/WEB-02/`).

### 3. Tornar os scripts executáveis

```bash
chmod +x /home/periciakali/WEB-02/dvwa_token.sh
chmod +x /home/periciakali/WEB-02/run_web02.sh
```

### 4. Testar a captura do token (isoladamente)

```bash
./dvwa_token.sh
```

**Saída esperada:** uma sequência alfanumérica (ex.: `d86e3c6b9e2a9c3e4f5a7b8c`).

**Se não retornar nada**, verifique:
- A DVWA está em nível **Medium** (não Low).
- A URL `http://192.168.1.11/dvwa/login.php` está acessível: `curl -I http://192.168.1.11/dvwa/login.php`.
- O campo `user_token` existe no HTML: `curl -s http://192.168.1.11/dvwa/login.php | grep user_token`.

### 5. Executar o ataque

```bash
./run_web02.sh
```

O script irá:
1. Capturar o token e o cookie de sessão.
2. Executar o Medusa com as wordlists.
3. Salvar a saída em `web02.log`.
4. Encerrar automaticamente ao encontrar a primeira credencial válida.

### 6. Verificar os resultados

```bash
grep SUCCESS web02.log
```

**Saída esperada:**
```
ACCOUNT FOUND: [http] Host: 192.168.1.11 User: admin Password: password [SUCCESS]
```

## 📸 Captura de tela
![Medusa output screenshot](image.png)

## 🛡️ Mitigações recomendadas

| Medida | Descrição |
|--------|-----------|
| **Token CSRF robusto** | Gerar um token único por requisição, vinculado à sessão, e validá‑lo no servidor. O nível *High* da DVWA implementa isso de forma mais segura. |
| **Rate‑limiting** | Limitar o número de tentativas de login por IP/sessão (ex.: `fail2ban`, `mod_evasive`). |
| **CAPTCHA** | Adicionar verificação humana (reCAPTCHA, hCaptcha) após N tentativas falhas. |
| **Bloqueio de conta** | Bloquear temporariamente a conta após múltiplas tentativas falhas consecutivas. |
| **Senhas fortes** | Exigir senhas com mínimo de 12 caracteres, mistura de maiúsculas, minúsculas, números e símbolos. |
| **Autenticação multifator (MFA)** | Adicionar uma segunda camada de verificação (ex.: OTP via app ou SMS). |
| **Monitoramento de logs** | Alertar quando houver picos de tentativas de login falhas vindas do mesmo IP. |
| **Headers de segurança** | Implementar `X-Frame-Options`, `Content-Security-Policy` e `SameSite` nos cookies. |

## 📝 Observações

> ⚠️ **Nota:** Durante a execução deste exercício, a captura automática do token pode falhar dependendo da configuração da DVWA e da versão do Metasploitable 2. Nesse caso, o token pode ser extraído manualmente via DevTools do navegador (aba **Network** → inspecionar a requisição POST → copiar o valor de `user_token`) e passado diretamente ao Medusa:
>
> ```bash
> medusa -h 192.168.1.11 \
>        -U users.txt \
>        -P pass_small.txt \
>        -M http \
>        -m "POST:/dvwa/login.php?username={user}&password={pass}&user_token=TOKEN_COPIADO" \
>        -t 6 -v 2 | tee web02.log
> ```

## 🔗 Referências
- Medusa – documentação: `man medusa` ou https://github.com/jmk-foofus/medusa
- DVWA – repositório oficial: https://github.com/digininja/DVWA
- OWASP – Cross‑Site Request Forgery (CSRF): https://owasp.org/www-community/attacks/csrf

---
*Este documento integra o repositório `bootcamp‑dio` e demonstra o cenário WEB‑02 — força bruta com contorno de proteção CSRF.*
