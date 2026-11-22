# 🛡️ Laboratório de Força Bruta com Medusa – BootCamp Anthropic (DIO)

> Projeto prático do BootCamp Anthropic da [DIO](https://dio.me) — simulação de ataques de força bruta em ambiente controlado usando **Kali Linux** e **Medusa**, com documentação completa e recomendações de mitigação.

⚠️ **Aviso Legal:** Este projeto foi desenvolvido exclusivamente para fins educacionais em ambiente controlado (máquinas virtuais isoladas). Nunca execute ataques de força bruta contra sistemas sem autorização explícita. O uso indevido dessas técnicas é crime previsto em lei.

---

## 📋 Sobre o Projeto

Este repositório documenta a realização de **6 cenários de ataque de força bruta** contra diferentes protocolos e serviços, utilizando a ferramenta **Medusa** a partir do **Kali Linux**. Os alvos são ambientes intencionalmente vulneráveis (**Metasploitable 2** e **DVWA**), configurados em rede isolada via VirtualBox.

### Objetivos de Aprendizagem

- ✅ Compreender ataques de força bruta em diferentes serviços (FTP, SMB, HTTP/Web).
- ✅ Utilizar o Kali Linux e o Medusa para auditoria de segurança em ambiente controlado.
- ✅ Documentar processos técnicos de forma clara e estruturada.
- ✅ Reconhecer vulnerabilidades comuns e propor medidas de mitigação.
- ✅ Utilizar o GitHub como portfólio técnico para compartilhar documentação e evidências.

---

## 🖥️ Ambiente de Laboratório

### Topologia de Rede

```
┌──────────────────────┐         ┌──────────────────────────────┐
│      Kali Linux      │         │      Metasploitable 2        │
│      (Atacante)      │◄───────►│         (Alvo)               │
│   192.168.1.10       │  Rede   │   192.168.1.11               │
│                      │ Host-   │                              │
│  Ferramentas:        │  Only   │  Serviços vulneráveis:       │
│  • Medusa v2.3       │         │  • FTP (vsftpd 2.3.4)       │
│  • cURL              │         │  • SMB (Samba 3.0.20)        │
│  • smbclient         │         │  • HTTP/DVWA (Apache + PHP)  │
│  • enum4linux        │         │                              │
└──────────────────────┘         └──────────────────────────────┘
```

### Máquinas Virtuais

| Máquina | Sistema Operacional | IP | Função |
|---------|--------------------|----|--------|
| **Kali Linux** | Kali Linux (rolling) | `192.168.1.10` | Atacante — executa o Medusa e ferramentas de auditoria |
| **Metasploitable 2** | Ubuntu 8.04 (vulnerável) | `192.168.1.11` | Alvo — roda FTP, SMB e DVWA |

### Configuração de Rede

- **Tipo:** Host-Only (rede isolada no VirtualBox).
- **Sub-rede:** `192.168.1.0/24`.
- **Gateway:** N/A (sem acesso à internet — ambiente 100% isolado).

---

## 🎯 Cenários de Ataque

O projeto está organizado em **6 cenários**, divididos por protocolo/serviço:

### 🔹 FTP — File Transfer Protocol (porta 21)

| Cenário | Descrição | Técnica | Credencial encontrada |
|---------|-----------|---------|----------------------|
| [**FTP‑01**](FTP-01/) | Força bruta simples — usuário único × lista de senhas | Brute Force (single user) | `msfadmin:msfadmin` |
| [**FTP‑02**](FTP-02/) | Força bruta com múltiplos usuários × múltiplas senhas | Dictionary Attack (multi‑user) | `msfadmin:msfadmin` |

### 🔹 SMB — Server Message Block (porta 445)

| Cenário | Descrição | Técnica | Credencial encontrada |
|---------|-----------|---------|----------------------|
| [**SMB‑01**](SMB-01/) | Password spraying — mesma senha testada em vários usuários | Password Spraying | `msfadmin:msfadmin` |
| [**SMB‑02**](SMB-02/) | Força bruta completa — vários usuários × várias senhas (módulo `smbnt`) | Brute Force (NTLM) | `msfadmin:msfadmin` (ADMIN$ Access) |

### 🔹 HTTP/Web — DVWA Login (porta 80)

| Cenário | Descrição | Técnica | Credenciais encontradas |
|---------|-----------|---------|------------------------|
| [**WEB‑01**](WEB-01/) | Força bruta simples no formulário de login (DVWA nível Low, sem token) | HTTP POST Brute Force | `msfadmin:password`, `admin:123456`, `root:123456`, `user:msfadmin` e outras |
| [**WEB‑02**](WEB-02/) | Força bruta com captura de token anti‑CSRF (DVWA nível Medium) | HTTP POST + CSRF Token Bypass | Exercício documentado com scripts de automação |

---

## 🔧 Ferramenta Principal: Medusa

**Medusa** é uma ferramenta de força bruta rápida, paralela e modular. Suporta diversos protocolos (FTP, HTTP, SMB, SSH, MySQL, entre outros).

### Instalação (Kali Linux)

```bash
sudo apt update && sudo apt install -y medusa
```

### Sintaxe básica

```bash
medusa -h <IP> -U <users.txt> -P <pass.txt> -M <modulo> [opções]
```

### Flags mais usadas neste projeto

| Flag | Descrição |
|------|-----------|
| `-h` | IP ou hostname do alvo |
| `-u` / `-U` | Usuário único (`-u`) ou arquivo com lista de usuários (`-U`) |
| `-p` / `-P` | Senha única (`-p`) ou arquivo com lista de senhas (`-P`) |
| `-M` | Módulo/protocolo (`ftp`, `http`, `smbnt`, `ssh`, etc.) |
| `-m` | Parâmetros adicionais do módulo (ex.: `DIR:/dvwa/login.php`) |
| `-t` | Número de threads (conexões paralelas) |
| `-f` | Parar ao encontrar a primeira credencial válida |
| `-v` | Nível de verbosidade (0 a 6) |

---

## 📂 Estrutura do Repositório

```
bootcamp-dio/
│
├── README.md                  ← Este arquivo (visão geral do projeto)
│
├── FTP-01/                    ← Cenário FTP – força bruta simples
│   ├── README.md              ← Documentação do cenário
│   ├── ftp01.log              ← Log completo do Medusa
│   └── ftp_image.png          ← Captura de tela
│
├── FTP-02/                    ← Cenário FTP – múltiplos usuários
│   ├── README.md
│   ├── ftp02.log
│   └── ftp02.png
│
├── SMB-01/                    ← Cenário SMB – password spraying
│   ├── README.md
│   ├── smb01.log
│   └── smbimagem01.png
│
├── SMB-02/                    ← Cenário SMB – força bruta NTLM
│   ├── README.md
│   ├── smb02.log
│   └── smbimagem02.png
│
├── WEB-01/                    ← Cenário HTTP – DVWA nível Low
│   ├── README.md
│   ├── web01.log
│   ├── webimagem01.png
│   └── webimagem02.png
│
└── WEB-02/                    ← Cenário HTTP – DVWA nível Medium (com token)
    ├── README.md
    ├── dvwa_token.sh          ← Script para captura do token anti-CSRF
    ├── run_web02.sh           ← Script de automação do ataque
    ├── users.txt              ← Wordlist de usuários
    └── pass_small.txt         ← Wordlist de senhas
```

---

## 🛡️ Recomendações de Mitigação

Após executar os cenários de ataque, ficam evidentes as vulnerabilidades causadas por **senhas fracas** e **falta de mecanismos de proteção**. Abaixo, um resumo das principais medidas de defesa:

### Por serviço

| Serviço | Mitigação |
|---------|-----------|
| **FTP** | Desativar ou substituir por SFTP/FTPS; configurar `fail2ban`; exigir senhas fortes; restringir acesso por IP. |
| **SMB** | Desativar SMBv1; usar SMBv2/v3; aplicar políticas de senha; habilitar bloqueio de conta após tentativas falhas; restringir acesso via firewall. |
| **HTTP/Web** | Implementar CAPTCHA e rate‑limiting; usar tokens CSRF robustos; bloquear contas após N falhas; exigir MFA; não revelar se o erro é de usuário ou senha. |

### Gerais

| Medida | Descrição |
|--------|-----------|
| 🔑 **Senhas fortes** | Mínimo 12 caracteres com maiúsculas, minúsculas, números e símbolos. |
| 🔐 **Autenticação multifator (MFA)** | Adicionar segunda camada de verificação (OTP, biometria, etc.). |
| 🚫 **Bloqueio de conta** | Bloquear temporariamente após X tentativas falhas consecutivas. |
| 🕐 **Rate‑limiting** | Limitar número de tentativas por IP/sessão por período de tempo. |
| 📊 **Monitoramento** | Alertas em tempo real para picos de tentativas de login falhas. |
| 🔄 **Atualizações** | Manter sistemas e serviços sempre atualizados com os patches mais recentes. |
| 🌐 **Segmentação de rede** | Isolar serviços críticos em redes separadas com firewalls dedicados. |

---

## 🚀 Como Reproduzir Este Laboratório

### 1. Instalar o VirtualBox
Baixe em: https://www.virtualbox.org/

### 2. Baixar e importar as VMs
- **Kali Linux:** https://www.kali.org/get-kali/#kali-virtual-machines
- **Metasploitable 2:** https://sourceforge.net/projects/metasploitable/files/Metasploitable2/

### 3. Configurar a rede Host‑Only
1. No VirtualBox → **Ferramentas** → **Rede** → criar rede Host-Only (`192.168.1.0/24`).
2. Em cada VM → **Configurações** → **Rede** → Adaptador 1 → **Placa em modo Host-Only**.

### 4. Configurar IPs estáticos
- **Kali:** `192.168.1.10`
- **Metasploitable 2:** `192.168.1.11`

### 5. Testar conectividade
```bash
ping 192.168.1.11    # do Kali para o Metasploitable
```

### 6. Clonar este repositório
```bash
git clone https://github.com/diegoferreira90/bootcamp-dio.git
cd bootcamp-dio
```

### 7. Executar os cenários
Acesse cada pasta e siga as instruções do README correspondente.

---

## 👤 Autor

**Diego Ferreira**
- GitHub: [@diegoferreira90](https://github.com/diegoferreira90)
- Plataforma de estudos: [DIO](https://dio.me)

---

## 📚 Referências

- [Medusa – Foofus Networks](https://github.com/jmk-foofus/medusa)
- [Metasploitable 2 – Rapid7](https://github.com/rapid7/metasploitable2)
- [DVWA – Damn Vulnerable Web Application](https://github.com/digininja/DVWA)
- [OWASP – Brute Force Attack](https://owasp.org/www-community/attacks/Brute_force_attack)
- [OWASP – CSRF](https://owasp.org/www-community/attacks/csrf)
- [Kali Linux](https://www.kali.org/)
- [VirtualBox](https://www.virtualbox.org/)

---

## 📄 Licença

Este projeto é de uso educacional. Sinta-se à vontade para usar como referência nos seus estudos.

---

> 🎓 *Projeto desenvolvido como parte do BootCamp Anthropic da [DIO – Digital Innovation One](https://dio.me).*
