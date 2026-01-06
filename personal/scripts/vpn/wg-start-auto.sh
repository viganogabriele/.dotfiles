#!/bin/bash

# --- CONFIGURAZIONE ---
TELEGRAM_TOKEN="8224768566:AAHHr3SH3qiTKYWSl9ZPH1BYb5vr8-n6qYM"   # <--- SOSTITUISCI IL TUO TOKEN
CHAT_ID="IL_TUO_CHAT_ID"             # <--- SOSTITUISCI IL TUO CHAT ID
COMMAND_START="/start"
WAIT_TIME=10 # Tempo in secondi per l'avvio del container remoto
INTERFACE="wg0"
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