# 🎵 Melody

> Application mobile de streaming musical moderne développée avec Flutter, intégrant Firebase et l'API Jamendo pour une expérience d'écoute premium.

---

## 📋 Table des matières

- [Aperçu](#aperçu)
- [Fonctionnalités](#fonctionnalités)
- [Captures d'écran](#captures-décran)
- [Architecture du projet](#architecture-du-projet)
- [Technologies utilisées](#technologies-utilisées)
- [Dépendances](#dépendances)
- [Installation](#installation)
- [Configuration Firebase](#configuration-firebase)
- [Lancement](#lancement)
- [Auteur](#auteur)

---

## 🎯 Aperçu

**Melody** est une application mobile de musique développée dans le cadre d'un TP de développement mobile. Elle permet aux utilisateurs de découvrir, écouter et gérer leur musique préférée grâce à une interface moderne avec des effets de glassmorphisme, des animations fluides et un support complet du mode clair/sombre.

L'application utilise l'API **Jamendo** comme source de musique libre de droits et **Firebase** pour l'authentification et le stockage des données utilisateur.

---

## ✨ Fonctionnalités

### 🔐 Authentification & Sécurité
- Inscription et connexion via **Firebase Auth** (email/mot de passe)
- Écran de récupération de mot de passe oublié
- Authentification biométrique (empreinte digitale / Face ID) via `local_auth`
- Écran Gateway sécurisé

### 🎶 Lecteur Audio
- Streaming audio haute qualité avec **just_audio**
- Lecture en arrière-plan avec notifications via **audio_service**
- Mini-player persistant dans la navigation
- Contrôles complets (play, pause, suivant, précédent, barre de progression)

### 📊 Dashboard & Statistiques
- Suivi des habitudes d'écoute
- Objectifs mensuels d'activité
- Graphiques interactifs avec **fl_chart**
- Métriques de temps d'écoute

### ❤️ Favoris
- Ajout/suppression de morceaux en favoris
- Synchronisation en temps réel avec **Cloud Firestore**
- Liste de favoris personnalisée

### 🎨 Interface Utilisateur Premium
- Design **glassmorphisme** avec cartes en verre dépoli
- Arrière-plans dynamiques animés
- Animations d'entrée décalées (staggered animations) via `flutter_animate`
- Support complet **Mode Clair** ☀️ et **Mode Sombre** 🌙
- Typographie moderne via **Google Fonts**

### ⚙️ Paramètres
- Basculement thème clair/sombre
- Configuration des préférences utilisateur
- Gestion du profil

---

## 🏗️ Architecture du projet

```
lib/
├── main.dart                         # Point d'entrée de l'application
├── firebase_options.dart             # Configuration Firebase auto-générée
│
├── core/                             # Logique métier
│   ├── models/
│   │   ├── track.dart                # Modèle de données Track (morceau)
│   │   └── user_model.dart           # Modèle de données User
│   ├── providers/
│   │   ├── music_provider.dart       # Provider état musique (ChangeNotifier)
│   │   └── theme_provider.dart       # Provider thème clair/sombre
│   └── services/
│       ├── audio_player_service.dart  # Service de lecture audio (singleton)
│       ├── biometric_service.dart     # Service authentification biométrique
│       ├── firebase_auth_service.dart # Service authentification Firebase
│       ├── firestore_service.dart     # Service Cloud Firestore (favoris, données)
│       ├── jamendo_api.dart          # Client API Jamendo
│       ├── jamendo_auth_service.dart  # Authentification OAuth Jamendo
│       └── stats_service.dart        # Service de statistiques d'écoute
│
├── navigation/
│   └── main_scaffold.dart            # Scaffold principal avec bottom nav + mini-player
│
├── screens/
│   ├── auth/
│   │   ├── gateway_screen.dart       # Écran d'accueil / gateway sécurisé
│   │   ├── login_screen.dart         # Écran de connexion
│   │   ├── signup_screen.dart        # Écran d'inscription
│   │   └── forgot_password_screen.dart # Récupération de mot de passe
│   └── main/
│       ├── home_screen.dart          # Écran d'accueil (découverte musicale)
│       ├── player_screen.dart        # Lecteur audio plein écran
│       ├── favorites_screen.dart     # Liste des favoris
│       ├── dashboard_screen.dart     # Tableau de bord & statistiques
│       └── settings_screen.dart      # Paramètres de l'application
│
├── theme/
│   └── app_theme.dart                # Définition des thèmes (clair & sombre)
│
└── widgets/
    ├── glass_card.dart               # Widget carte glassmorphisme réutilisable
    └── ambient_background.dart       # Widget arrière-plan dynamique animé
```

---

## 🛠️ Technologies utilisées

| Technologie | Usage |
|---|---|
| **Flutter** `SDK ^3.11.0` | Framework de développement mobile cross-platform |
| **Dart** | Langage de programmation |
| **Firebase Auth** | Authentification utilisateur (email/mot de passe) |
| **Cloud Firestore** | Base de données NoSQL temps réel (favoris, profils) |
| **Jamendo API** | Source de musique libre de droits |
| **Provider** | Gestion d'état réactive |
| **just_audio** | Moteur de lecture audio |
| **audio_service** | Lecture audio en arrière-plan |

---

## 📦 Dépendances

### Production

| Package | Version | Description |
|---|---|---|
| `firebase_core` | ^3.6.0 | Initialisation Firebase |
| `firebase_auth` | ^5.3.1 | Authentification Firebase |
| `cloud_firestore` | ^5.4.4 | Base de données Firestore |
| `just_audio` | ^0.9.40 | Lecteur audio |
| `audio_service` | ^0.18.15 | Service audio en arrière-plan |
| `just_audio_background` | ^0.0.1-beta.13 | Intégration background audio |
| `audio_session` | ^0.1.18 | Gestion session audio |
| `provider` | ^6.1.1 | State management |
| `local_auth` | ^2.3.0 | Authentification biométrique |
| `google_fonts` | ^8.0.2 | Polices Google |
| `flutter_animate` | ^4.5.2 | Animations fluides |
| `fl_chart` | ^0.69.0 | Graphiques et charts |
| `http` | ^1.2.1 | Requêtes HTTP (API Jamendo) |
| `flutter_web_auth_2` | ^5.0.0 | OAuth web authentication |
| `shared_preferences` | ^2.3.2 | Stockage local persistant |
| `app_settings` | ^5.1.1 | Accès aux paramètres système |

### Développement

| Package | Version | Description |
|---|---|---|
| `flutter_lints` | ^6.0.0 | Règles de linting |
| `flutter_launcher_icons` | ^0.14.3 | Génération d'icônes |
| `flutter_native_splash` | ^2.4.4 | Splash screen natif |

---

## 🚀 Installation

### Prérequis

- **Flutter SDK** `^3.11.0` installé ([guide d'installation](https://docs.flutter.dev/get-started/install))
- **Android Studio** ou **VS Code** avec les extensions Flutter/Dart
- Un projet **Firebase** configuré
- Un compte développeur **Jamendo** (pour la clé API)
- Un appareil Android/iOS ou un émulateur

### Étapes

1. **Cloner le dépôt**
   ```bash
   git clone https://github.com/hich-am/melodytests.git
   cd melodytests
   ```

2. **Installer les dépendances**
   ```bash
   flutter pub get
   ```

3. **Générer les icônes et splash screen**
   ```bash
   dart run flutter_launcher_icons
   dart run flutter_native_splash:create
   ```

---

## 🔥 Configuration Firebase

1. Créer un projet sur la [console Firebase](https://console.firebase.google.com/)

2. Activer **Authentication** (fournisseur Email/Mot de passe)

3. Activer **Cloud Firestore**

4. Ajouter votre application Android :
   - Nom du package : `com.melody.app.melody`
   - Télécharger `google-services.json`
   - Le placer dans `android/app/`

5. *(Optionnel)* Configurer avec FlutterFire CLI :
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

---

## ▶️ Lancement

```bash
# Mode debug
flutter run

# Mode release
flutter run --release

# Build APK
flutter build apk
```

---

## 📱 Navigation de l'application

```
Gateway Screen (démarrage)
    ├── Login Screen ──────────────┐
    ├── Signup Screen ─────────────┤
    └── Forgot Password Screen     │
                                   ▼
                        Main Scaffold (bottom nav)
                           ├── 🏠 Home (découverte)
                           ├── ❤️ Favoris
                           ├── 📊 Dashboard
                           ├── ⚙️ Paramètres
                           └── 🎵 Player (plein écran)
```

---

## 👨‍💻 Auteurs

Projet réalisé par **HICHAM** et **TADJ EDDINE** dans le cadre du **TP Développement Mobile** — Application Flutter avec Firebase.

---

<p align="center">
  Fait avec ❤️ et Flutter 🎵
</p>
