#!/usr/bin/env bash
# dvwa_token.sh – captura o token anti-CSRF (user_token) da página de login da DVWA
# Uso: ./dvwa_token.sh
# Saída: imprime apenas o valor do token (sem newline)

URL="http://192.168.1.11/dvwa/login.php"
COOKIE_JAR="/tmp/dvwa_cookie.jar"

# 1) Baixa a página de login e salva o cookie de sessão (PHPSESSID)
curl -s -L -c "$COOKIE_JAR" -A "Mozilla/5.0" "$URL" -o /tmp/dvwa_login.html

if [[ $? -ne 0 ]]; then
  echo "ERRO: falha ao acessar $URL" >&2
  exit 1
fi

# 2) Extrai o valor do campo hidden user_token
TOKEN=$(grep -oP 'name="user_token"\s+value="\K[^"]+' /tmp/dvwa_login.html)

if [[ -z "$TOKEN" ]]; then
  echo "ERRO: campo user_token não encontrado no HTML." >&2
  echo "Verifique se a DVWA está em nível medium e se a URL está correta." >&2
  exit 2
fi

echo -n "$TOKEN"
