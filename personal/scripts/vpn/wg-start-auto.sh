#!/bin/bash
# da correggere tutto il codice


# --- ENV ---
ENV_FILE="$(dirname "$0")/.env"

if [ -f "$ENV_FILE" ]; then
    export $(grep -v '^#' "$ENV_FILE" | xargs)
else
    echo "!!! File .env non trovato in $ENV_FILE"
    exit 1
fi
# ----------------------

echo "--> Invio comando di avvio ('${COMMAND_START}') al bot Telegram..."
curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
     -d chat_id="${CHAT_ID}" \
     -d text="${COMMAND_START}" > /dev/null

if [ $? -ne 0 ]; then
    echo "!!! Errore nell'invio del messaggio a Telegram. Verifica Token e Chat ID."
    exit 1
fi

echo "--> Attesa di ${WAIT_TIME} secondi per l'avvio del container WireGuard..."
sleep ${WAIT_TIME}

echo "--> Tentativo di avvio dell'interfaccia WireGuard (${INTERFACE})..."
sudo wg-quick up "${INTERFACE}"

if [ $? -eq 0 ]; then
    echo ">>> Connessione WireGuard stabilita con successo."
else
    echo "!!! Errore nell'avvio di WireGuard. Controlla la configurazione o lo stato del server."
fi