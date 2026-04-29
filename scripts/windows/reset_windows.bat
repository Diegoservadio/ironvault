@echo off
:: ================================================================
:: IronVault — Reset Windows
:: DN Security Labs — ITS Academy Tech Talent Factory 2024-2026
:: ================================================================
:: Pulisce i file .locked dalle cartelle di rete e locali
:: dopo una simulazione di attacco ransomware.
:: Da eseguire sul PC PMI-Reception (laura.bianchi)
:: ================================================================

echo === IRONVAULT - Reset Windows ===

echo [1/4] Pulizia file .locked su F: ...
del /f /q "F:\*.locked" 2>nul

echo [2/4] Pulizia file .locked su G: ...
del /f /q "G:\*.locked" 2>nul

echo [3/4] Pulizia file .locked su H: ...
del /f /q "H:\*.locked" 2>nul

echo [4/4] Pulizia file locali ...
del /f /q "C:\Users\laura.bianchi\Documents\*.locked" 2>nul
del /f /q "C:\Users\laura.bianchi\Downloads\*.locked" 2>nul
del /f /q "C:\Users\laura.bianchi\chiave_demo.key" 2>nul

echo.
echo Reset Windows completato!
echo === IRONVAULT - Reset completato ===
