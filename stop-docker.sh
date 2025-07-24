#!/bin/bash

# Script d'arrêt Docker pour Newsletter KCS

echo "🛑 Arrêt de l'application Newsletter KCS"
echo "======================================="
echo ""

# Arrêter et supprimer les containers
echo "🔧 Arrêt des services..."
if command -v docker-compose &> /dev/null; then
    docker-compose down
else
    docker compose down
fi

echo ""
echo "🧹 Nettoyage optionnel:"
echo "   Pour supprimer les volumes (données): docker-compose down -v"
echo "   Pour supprimer les images: docker system prune -a"
echo ""
echo "✅ Services arrêtés avec succès!"
