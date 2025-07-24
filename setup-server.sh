#!/bin/bash

# Configuration du serveur après déploiement
VPS_IP="167.86.93.157"
VPS_USER="vpsadmin"
DOMAIN="newslettre.kcs.zidani.org"
APP_NAME="newslettre"
DEPLOY_DIR="/home/vpsadmin/$APP_NAME"

echo "🔧 Configuration du serveur pour Newsletter KCS"
echo "=============================================="
echo "VPS: $VPS_USER@$VPS_IP"
echo "Domaine: $DOMAIN"
echo ""

# Connexion SSH et configuration du serveur
ssh $VPS_USER@$VPS_IP << EOF
echo "📦 Mise à jour du système..."
sudo apt update && sudo apt upgrade -y

echo "🐳 Installation de Docker et Docker Compose..."
# Installation de Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $VPS_USER

# Installation de Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-\$(uname -s)-\$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "🌐 Installation de Nginx..."
sudo apt install nginx -y

echo "🔥 Configuration du firewall..."
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw allow 3001/tcp
sudo ufw allow 5050/tcp
sudo ufw --force enable

echo "📁 Configuration des répertoires..."
sudo mkdir -p $DEPLOY_DIR/public/uploads
sudo chown -R $VPS_USER:$VPS_USER $DEPLOY_DIR
chmod 755 $DEPLOY_DIR/public/uploads

echo "🔧 Configuration de Nginx..."
sudo tee /etc/nginx/sites-available/$DOMAIN > /dev/null << 'NGINX_CONFIG'
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    location /pgadmin/ {
        proxy_pass http://localhost:5050/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }

    location /uploads/ {
        alias $DEPLOY_DIR/public/uploads/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    access_log /var/log/nginx/$DOMAIN.access.log;
    error_log /var/log/nginx/$DOMAIN.error.log;
}
NGINX_CONFIG

echo "🔗 Activation du site Nginx..."
sudo ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx

echo "🔒 Installation de Certbot pour SSL..."
sudo apt install snapd -y
sudo snap install core; sudo snap refresh core
sudo snap install --classic certbot
sudo ln -sf /snap/bin/certbot /usr/bin/certbot

echo "📜 Génération du certificat SSL..."
sudo certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email admin@kcs.zidani.org

echo "🔄 Configuration du renouvellement automatique SSL..."
echo "0 12 * * * /usr/bin/certbot renew --quiet" | sudo crontab -

echo "🐳 Redémarrage de Docker (pour les permissions)..."
sudo systemctl restart docker

echo "✅ Configuration du serveur terminée!"
echo ""
echo "🌐 Votre application sera accessible à:"
echo "   - HTTPS: https://$DOMAIN"
echo "   - HTTP: http://$DOMAIN (redirection vers HTTPS)"
echo "   - pgAdmin: https://$DOMAIN/pgadmin/"
echo ""
echo "📋 Informations importantes:"
echo "   - Répertoire de l'app: $DEPLOY_DIR"
echo "   - Logs Nginx: /var/log/nginx/$DOMAIN.*.log"
echo "   - Certificat SSL: /etc/letsencrypt/live/$DOMAIN/"
echo ""
echo "🔧 Commandes utiles:"
echo "   - Voir les containers: docker-compose -f $DEPLOY_DIR/docker-compose.prod.yml ps"
echo "   - Voir les logs: docker-compose -f $DEPLOY_DIR/docker-compose.prod.yml logs -f"
echo "   - Redémarrer: docker-compose -f $DEPLOY_DIR/docker-compose.prod.yml restart"
EOF

echo ""
echo "🎉 Configuration du serveur terminée!"
echo ""
echo "📝 Prochaines étapes:"
echo "   1. Vérifier que le domaine pointe vers votre VPS ($VPS_IP)"
echo "   2. Configurer la clé OpenAI dans $DEPLOY_DIR/.env.local"
echo "   3. Tester l'application sur https://$DOMAIN"
