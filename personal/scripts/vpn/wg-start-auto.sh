#!/bin/bash
import os
from dotenv import load_dotenv

load_dotenv()


# --- ENV ---
TELEGRAM_TOKEN=os.getenv("TELEGRAM_TOKEN") 
CHAT_ID=os.getenv("CHAT_ID")             
COMMAND_START=os.getenv("COMMAND_START")
WAIT_TIME=int(os.getenv("WAIT_TIME"))
INTERFACE=os.getenv("INTERFACE")
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