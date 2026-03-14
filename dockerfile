FROM cirrusci/flutter:stable

RUN apt-get update && apt-get install -y nodejs npm && rm -rf /var/lib/apt/lists/*

RUN npm install -g firebase-tools

WORKDIR /app

# Copier les fichiers de dépendances d'abord pour optimiser le cache
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copier le reste du code source
COPY . .

# Créer le fichier .env pour le build
RUN echo "API_KEY_BROWSER=${API_KEY_BROWSER:-}" >> .env && \
    echo "API_KEY_ANDROID=${API_KEY_ANDROID:-}" >> .env && \
    echo "API_KEY_IOS=${API_KEY_IOS:-}" >> .env && \
    echo "API_KEY_MACOS=${API_KEY_MACOS:-}" >> .env && \
    echo "API_KEY_WINDOWS=${API_KEY_WINDOWS:-}" >> .env

# Build pour différentes plateformes
RUN flutter build web --release
RUN flutter build apk --release

# Exposer les ports pour le développement
EXPOSE 8080

# Commande par défaut pour garder le container actif
CMD ["tail", "-f", "/dev/null"]