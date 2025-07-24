#!/bin/bash

echo "🚀 Démarrage de l'environnement Supabase local pour Newsletter KCS"
echo "=================================================================="

# Vérifier si Docker est installé
if ! command -v docker &> /dev/null; then
    echo "❌ Docker n'est pas installé. Veuillez installer Docker Desktop."
    exit 1
fi

# Vérifier si Docker Compose est installé
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose n'est pas installé. Veuillez installer Docker Compose."
    exit 1
fi

echo "✅ Docker et Docker Compose sont installés"

# Arrêter les containers existants
echo "🛑 Arrêt des containers existants..."
docker-compose down

# Supprimer les volumes pour un redémarrage propre (optionnel)
read -p "Voulez-vous supprimer les données existantes ? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🗑️  Suppression des volumes existants..."
    docker-compose down -v
    docker volume prune -f
fi

# Démarrer les services
echo "🚀 Démarrage des services Supabase..."
docker-compose up -d

# Attendre que les services soient prêts
echo "⏳ Attente du démarrage des services..."
sleep 10

# Vérifier l'état des services
echo "📊 État des services:"
docker-compose ps

echo ""
echo "🎉 Supabase est maintenant disponible !"
echo "=================================="
echo "📊 Supabase Studio (Interface d'admin): http://localhost:3000"
echo "🔗 API REST: http://localhost:8000/rest/v1/"
echo "🔐 Auth: http://localhost:8000/auth/v1/"
echo "📧 MailHog (Emails de test): http://localhost:8025"
echo "🗄️  PostgreSQL: localhost:5432"
echo ""
echo "🔑 Clés d'API:"
echo "   ANON_KEY: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0"
echo "   SERVICE_KEY: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU"
echo ""
echo "💡 Pour arrêter les services: docker-compose down"
echo "💡 Pour voir les logs: docker-compose logs -f"
echo ""
echo "🚀 Vous pouvez maintenant démarrer votre application Next.js !"
echo "   cd app && npm run dev"
