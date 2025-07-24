Write-Host "🚀 Démarrage de l'environnement Supabase local pour Newsletter KCS" -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Green

# Vérifier si Docker est installé
try {
    docker --version | Out-Null
    Write-Host "✅ Docker est installé" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker n'est pas installé. Veuillez installer Docker Desktop." -ForegroundColor Red
    exit 1
}

# Vérifier si Docker Compose est installé
try {
    docker-compose --version | Out-Null
    Write-Host "✅ Docker Compose est installé" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker Compose n'est pas installé. Veuillez installer Docker Compose." -ForegroundColor Red
    exit 1
}

# Arrêter les containers existants
Write-Host "🛑 Arrêt des containers existants..." -ForegroundColor Yellow
docker-compose down

# Demander si on veut supprimer les données
$response = Read-Host "Voulez-vous supprimer les données existantes ? (y/N)"
if ($response -eq "y" -or $response -eq "Y") {
    Write-Host "🗑️  Suppression des volumes existants..." -ForegroundColor Yellow
    docker-compose down -v
    docker volume prune -f
}

# Démarrer les services
Write-Host "🚀 Démarrage des services Supabase..." -ForegroundColor Green
docker-compose up -d

# Attendre que les services soient prêts
Write-Host "⏳ Attente du démarrage des services..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Vérifier l'état des services
Write-Host "📊 État des services:" -ForegroundColor Cyan
docker-compose ps

Write-Host ""
Write-Host "🎉 Supabase est maintenant disponible !" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host "📊 Supabase Studio (Interface d'admin): http://localhost:3000" -ForegroundColor Cyan
Write-Host "🔗 API REST: http://localhost:8000/rest/v1/" -ForegroundColor Cyan
Write-Host "🔐 Auth: http://localhost:8000/auth/v1/" -ForegroundColor Cyan
Write-Host "📧 MailHog (Emails de test): http://localhost:8025" -ForegroundColor Cyan
Write-Host "🗄️  PostgreSQL: localhost:5432" -ForegroundColor Cyan
Write-Host ""
Write-Host "🔑 Clés d'API:" -ForegroundColor Yellow
Write-Host "   ANON_KEY: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0" -ForegroundColor Gray
Write-Host "   SERVICE_KEY: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU" -ForegroundColor Gray
Write-Host ""
Write-Host "💡 Pour arrêter les services: docker-compose down" -ForegroundColor Magenta
Write-Host "💡 Pour voir les logs: docker-compose logs -f" -ForegroundColor Magenta
Write-Host ""
Write-Host "🚀 Vous pouvez maintenant démarrer votre application Next.js !" -ForegroundColor Green
Write-Host "   cd app && npm run dev" -ForegroundColor Cyan
