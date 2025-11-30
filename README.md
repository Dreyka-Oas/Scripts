# 🛠️ Boîte à Outils & Scripts

Ce dossier regroupe des utilitaires d'automatisation (scripts Batch Windows) conçus pour simplifier l'analyse de projets, la documentation technique et la préparation de contexte pour les IA.

## 📂 Outils Disponibles

### 1. 🌳 Générateur d'Arborescence
*Utilitaire de visualisation de structure.*

Ce script génère une vue hiérarchique propre de vos dossiers. Il est idéal pour comprendre l'architecture d'un projet sans être pollué par les fichiers techniques inutiles.

*   **Fonction :** Crée un fichier texte (`architecture_filtree.txt`) représentant l'arbre des fichiers.
*   **Filtrage Intelligent :** Ignore automatiquement les dossiers lourds (`node_modules`, `.git`, `dist`, etc.) et les fichiers binaires/système.
*   **Nettoyage :** Masque les fichiers vides (0 octet) pour alléger la lecture.

---

### 2. 📄 Extracteur de Contenu & Code
*Utilitaire d'agrégation de fichiers.*

Ce script parcourt un projet pour récupérer le **contenu texte** de tous les fichiers de code et de documentation, et les compile dans un seul fichier de résultat (`resultats_recherche.txt`). C'est l'outil parfait pour fournir l'intégralité du code source d'un projet à une IA (ChatGPT, Claude, etc.) en une seule fois.

*   **Modes de sortie :**
    *   **Mode Markdown :** Formate chaque fichier dans un bloc de code (```) avec son chemin d'accès.
    *   **Mode Compact :** Supprime les lignes vides pour économiser de l'espace.
*   **Sécurité & Filtres :**
    *   Exclut les images, vidéos, exécutables et archives.
    *   Ignore les fichiers de configuration lourds (`package-lock.json`) et les dossiers caches.
    *   Ne traite que les fichiers lisibles.

## 🚀 Utilisation

1.  Double-cliquez sur le script souhaité (`.bat`).
2.  L'invite de commande s'ouvre.
3.  **Indiquez le chemin** du dossier à analyser (ou appuyez sur Entrée pour analyser le dossier courant).
4.  Récupérez le fichier de résultat généré dans le même dossier.

## ⚙️ Informations Techniques

*   **Plateforme :** Windows uniquement.
*   **Encodage :** UTF-8 (Support complet des accents).
*   **Performance :** Les deux scripts utilisent des boucles récursives optimisées pour ne pas scanner les dossiers exclus (gain de temps sur les gros projets `npm` ou `python`).