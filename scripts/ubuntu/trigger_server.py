#!/usr/bin/env python3
"""
IronVault — Trigger Server
DN Security Labs — ITS Academy Tech Talent Factory 2024-2026

HTTP server in ascolto sulla porta 8888.
Riceve GET /attacca dal ransomware Windows e lancia
lo script ransomware su Ubuntu in un thread separato.

Avvio: nohup python3 trigger_server.py > /tmp/trigger.log 2>&1 &
"""

import http.server
import threading
import subprocess
import logging
from datetime import datetime

PORT = 8888
SCRIPT_PATH = "/home/pmiuser/ransomware_sim.py"

logging.basicConfig(
    level=logging.INFO,
    format='[%(asctime)s] %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)

class TriggerHandler(http.server.BaseHTTPRequestHandler):

    def do_GET(self):
        if self.path == '/attacca':
            logging.info(f"Segnale attacco ricevuto da {self.client_address[0]}")
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"attacco avviato")
            # Lancia lo script in thread separato
            t = threading.Thread(target=self._lancia_attacco, daemon=True)
            t.start()
        elif self.path == '/':
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"server attivo")
        else:
            self.send_response(404)
            self.end_headers()

    def _lancia_attacco(self):
        logging.info("Avvio ransomware_sim.py su Ubuntu...")
        try:
            result = subprocess.run(
                ['python3', SCRIPT_PATH],
                capture_output=True, text=True, timeout=120
            )
            logging.info(f"Script completato — return code: {result.returncode}")
        except Exception as e:
            logging.error(f"Errore lancio script: {e}")

    def log_message(self, format, *args):
        # Silenzia i log HTTP standard, usiamo il nostro
        pass

if __name__ == '__main__':
    server = http.server.HTTPServer(('0.0.0.0', PORT), TriggerHandler)
    logging.info(f"Trigger server avviato — porta {PORT}")
    logging.info("In attesa di segnale su GET /attacca")
    server.serve_forever()
