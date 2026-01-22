# DigitalBank — Architecture & Guide

Ce document décrit l'architecture du projet DigitalBank, ses composants, le flux de données, les contrats d'API, les opérations courantes (exécution, entraînement, tests) et les points d'intégration pour fournir ces informations à une autre IA ou équipe.

## Vue d'ensemble
- Objectif principal : détecter les transactions frauduleuses en temps (ou quasi-temps) réel via une API exposant un modèle de ML entraîné.
- Composants principaux :
  - `fraud_detection_api` : API et scripts ML
  - `Grafana` : observabilité (Grafana, Prometheus, dashboards, règles d'alerte)
  - `supabase_config` : schéma de base de données et politiques

## Arborescence principale
- [fraud_detection_api](fraud_detection_api) — code API et ML
- [Grafana](Grafana) — docker-compose, configuration Prometheus et dashboards
- [supabase_config](supabase_config) — `schema.sql` et `policies.sql`

## Composants détaillés

- API (point d'entrée)
  - Fichier : [fraud_detection_api/app.py](fraud_detection_api/app.py)
  - Rôle : recevoir requêtes transactionnelles, prétraiter, appeler le modèle, renvoyer JSON (probabilité/étiquette), exposer métriques pour Prometheus.

- Génération / entraînement du modèle
  - Fichier : [fraud_detection_api/generate_model.py](fraud_detection_api/generate_model.py)
  - Rôle : charger jeux de données (ex. [fraud_detection_api/sample_transactions.csv](fraud_detection_api/sample_transactions.csv)), faire feature engineering, entraîner et sauvegarder l'artefact modèle (pickle/joblib ou autre).

- Tests & exemples
  - Fichier : [fraud_detection_api/test_requests.py](fraud_detection_api/test_requests.py)
  - Rôle : scripts clients pour valider l'API et vérifier les réponses du modèle.

- Observabilité
  - Fichiers clés : [Grafana/docker-compose.yml](Grafana/docker-compose.yml), [Grafana/prometheus/prometheus.yml](Grafana/prometheus/prometheus.yml) (si présent), [Grafana/prometheus/alert.rules.yml](Grafana/prometheus/alert.rules.yml)
  - Rôle : Prometheus scrape l'API (endpoint `/metrics`); Grafana visualise et alerte.

- Stockage & sécurité
  - Fichiers : [supabase_config/schema.sql](supabase_config/schema.sql), [supabase_config/policies.sql](supabase_config/policies.sql)
  - Rôle : structure des tables (transactions, alerts, modèles, logs) et politiques Row-Level Security.

## Flux de données (End-to-end)
1. Client envoie `POST /predict` (ou endpoint équivalent) à l'API avec payload JSON décrivant la transaction.
2. `app.py` valide et normalise les champs, extrait les features attendues.
3. Le modèle prédit une probabilité d'anomalie / label fraude.
4. L'API renvoie JSON avec `fraud_probability`, `is_fraud`, `model_version` et éventuellement un `explanation` succinct.
5. Si condition d'alerte remplie, écrire une ligne dans la table `alerts` (Supabase) et/ou déclencher un webhook/alerte.
6. Prometheus collecte métriques (latence, compte requêtes, taux de fraudes détectées) et Grafana alerte selon `alert.rules.yml`.

## Contrat API (exemple)
- Endpoint (exemple) : `POST /predict`
- Requête (JSON) :
  - `transaction_id` : string
  - `timestamp` : ISO8601
  - `amount` : number
  - `currency` : string
  - `origin_account` : string
  - `destination_account` : string
  - `merchant` : string (optionnel)
  - autres champs métier requis
- Réponse (JSON) :
  - `fraud_probability` : float (0.0–1.0)
  - `is_fraud` : boolean
  - `model_version` : string
  - `explanation` : object (optionnel, p.ex. features importantes)

Note : documenter précisément les noms et formats de features dans `generate_model.py` pour garantir compatibilité entre entraînement et inference.

## Observabilité recommandée
- Endpoints/métriques : exposer `/metrics` compatible Prometheus.
- Métriques minimales : `requests_total`, `request_latency_seconds`, `predictions_total`, `frauds_detected_total`, `model_load_time_seconds`.
- Dashboards : taux de requêtes, latence, distribution des probabilités de fraude, nombre d'alertes, version de modèle en production.

## Exécution locale (commande typiques)

1) Lancer l'API (selon implémentation) :
```bash
python fraud_detection_api/app.py
# ou si Flask app définie : flask run
```

2) Entraîner/générer le modèle :
```bash
python fraud_detection_api/generate_model.py
```

3) Tester l'API :
```bash
python fraud_detection_api/test_requests.py
```

4) Lancer stack monitoring localement :
```bash
docker-compose -f Grafana/docker-compose.yml up --build -d
```

Variables d'environnement courantes à définir : `DB_URL`, `SUPABASE_KEY`, `MODEL_PATH`, `FLASK_ENV`, `PORT`, `PROMETHEUS_TARGETS`.

## Supabase / Base de données
- Utilisation : stocker transactions historiques, alertes, logs et métadonnées modèle.
- Mise en place : exécuter [supabase_config/schema.sql](supabase_config/schema.sql) pour créer tables, puis [supabase_config/policies.sql](supabase_config/policies.sql) pour appliquer les politiques.

## Sécurité & conformité
- Ne jamais stocker de PII non chiffrée : anonymiser ou tokeniser les numéros de carte et autres données sensibles.
- Gérer les secrets via vault/variables d'environnement (ne pas hardcoder dans le code).
- Activer Row-Level Security et politiques strictes dans Supabase.

## Déploiement (suggestions)
- Containeriser l'API (`Dockerfile`) et déployer via Docker Compose / Kubernetes.
- Versionner les modèles (p.ex. `model_v1.0.pkl`) et stocker métadonnées (date, métriques d'évaluation).
- Mettre en place pipeline CI pour tests automatiques et mise à jour du modèle.

## Tests & validation
- Utiliser [fraud_detection_api/test_requests.py](fraud_detection_api/test_requests.py) pour tests fonctionnels.
- Préparer jeux de tests unitaires pour le prétraitement et la logique métier.

## Pour une autre IA : informations utiles à demander
- Format exact des features : noms, types, encodages catégoriels, valeurs manquantes, normalisation.
- Emplacement et format de l'artefact modèle (pickle/joblib/onnx) et comment le recharger.
- Contrats d'API exacts (noms de champs requis / optionnels).
- Secrets / accès nécessaires pour Supabase et monitoring (endpoints, credentials).
- Environnement cible de déploiement (containers, k8s, serverless).
- Seuils métier : tolérance aux faux positifs / faux négatifs, règles d'escalade.

## Fichiers de référence
- [fraud_detection_api/app.py](fraud_detection_api/app.py)
- [fraud_detection_api/generate_model.py](fraud_detection_api/generate_model.py)
- [fraud_detection_api/test_requests.py](fraud_detection_api/test_requests.py)
- [fraud_detection_api/sample_transactions.csv](fraud_detection_api/sample_transactions.csv)
- [Grafana/docker-compose.yml](Grafana/docker-compose.yml)
- [supabase_config/schema.sql](supabase_config/schema.sql)
- [supabase_config/policies.sql](supabase_config/policies.sql)

---

Si tu veux, je peux maintenant :
- extraire automatiquement le contrat d'API depuis `app.py`,
- générer un `requirements.txt` basé sur le code,
- ou créer un `Dockerfile` + `docker-compose` pour l'API.

Indique quelle action tu préfères ensuite.
# digitalbank