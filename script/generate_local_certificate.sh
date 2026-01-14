#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== Génération des certificats SSL locaux ===${NC}\n"

# Vérifier si mkcert est installé
if ! command -v mkcert &> /dev/null; then
    echo -e "${RED}❌ mkcert n'est pas installé${NC}\n"
    exit 1
fi

# Désinstaller puis réinstaller le CA (pour être sûr)
echo -e "${YELLOW}Réinstallation de l'autorité de certification...${NC}"
mkcert -uninstall 2>/dev/null
mkcert -install

# Créer le dossier
mkdir -p ./.docker/traefik/cert

# Générer les certificats
echo -e "\n${YELLOW}Génération des certificats...${NC}"
mkcert -cert-file ./.docker/traefik/cert/local-cert.pem \
       -key-file ./.docker/traefik/cert/local-key.pem \
       "*.yoda_grammar.docker" \
       "yoda_grammar.docker" \
       "localhost"

echo -e "\n${GREEN}✓ Certificats générés !${NC}"
echo -e "\n${YELLOW}⚠️  IMPORTANT:${NC}"
echo -e "1. ${YELLOW}Fermez COMPLÈTEMENT votre navigateur${NC}"
echo -e "2. Relancez-le"
echo -e "3. Si vous utilisez Firefox, importez manuellement le CA:"
echo -e "   ${GREEN}$(mkcert -CAROOT)/rootCA.pem${NC}"
echo -e "\n${GREEN}Puis lancez: make start${NC}"
