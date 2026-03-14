# Configuration des variables d'environnement

Ce projet utilise `flutter_dotenv` pour gérer les clés API Firebase de manière sécurisée.

## Étapes de configuration

1. **Copier le fichier d'exemple** :
   ```bash
   cp .env.example .env
   ```

2. **Remplacer les clés API** dans le fichier `.env` avec vos vraies clés Firebase :
   ```
   # Firebase API Keys
   API_KEY_BROWSER=votre_vraie_cle_api_browser
   API_KEY_ANDROID=votre_vraie_cle_api_android
   API_KEY_IOS=votre_vraie_cle_api_ios
   API_KEY_MACOS=votre_vraie_cle_api_macos
   API_KEY_WINDOWS=votre_vraie_cle_api_windows
   ```

## Où trouver vos clés API Firebase

1. Allez dans la [console Firebase](https://console.firebase.google.com/)
2. Sélectionnez votre projet
3. Cliquez sur l'icône d'engrenage ⚙️ → Paramètres du projet
4. Allez dans la section "Vos applications"
5. Pour chaque plateforme (Web, Android, iOS, etc.), cliquez sur l'application et trouvez la clé API

## Sécurité

- Le fichier `.env` est déjà inclus dans `.gitignore` et ne sera pas partagé sur Git
- Le fichier `.env.example` sert de modèle et peut être partagé
- Les clés sont chargées au démarrage de l'application via `flutter_dotenv`

## Structure des fichiers

- `lib/config/secrets.dart` : Classe qui accède aux variables d'environnement
- `lib/firebase_options.dart` : Configuration Firebase qui utilise les secrets
- `.env` : Fichier local avec vos vraies clés (non versionné)
- `.env.example` : Fichier modèle versionné
