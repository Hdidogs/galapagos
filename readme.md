# Système Logistique de l'archipel Galapagos 

Ce projet est une application de **visualisation logistique et d'optimisation de tournées** pour un archipel (basé sur les Galápagos). Il utilise une architecture avec une double base de donnée unifiée grâce a une API **GraphQL**.

L'objectif est de visualiser une flotte d'hydravions, des stocks de produits scientifiques, et de calculer les itinéraires de livraison optimaux en tenant compte des contraintes géographiques et matérielles.

## 🛠️ Stack Technologique

### Backend

* **Runtime :** Node.js
* **API :** Apollo Server (GraphQL)
* **Graph Database :** Neo4j (Gère la topologie, la géolocalisation et le routing)
* **Document Database :** MongoDB (Gère les données métier, clients, stocks et historique)
* **Drivers :** `mongoose`, `neo4j-driver`

### Frontend (SPA)

* **Framework :** Vue.js 3 (Composition API via CDN)
* **UI :** Tailwind CSS (via CDN)
* **Cartographie :** Leaflet.js (OpenStreetMap)

-----

## 🗄️ Architecture des Données (Répartition)

Le système tire parti des forces de chaque base de données : Neo4j pour les relations spatiales et MongoDB pour la flexibilité des documents métier 85].

### 1\. Neo4j (Données Spatiales & Flotte)

Stocke la géographie de l'archipel et l'état physique des avions.

| Label (Entité) | Propriétés Clés | Description                                            |
| :--- | :--- |:-------------------------------------------------------|
| **`Seaplane`** | `id`, `model`, `status`, `fuel`, `capacity`, `location` (Point) | Représente un hydravion et sa position GPS temps réel. |
| **`Island`** | `island_code`, `name`, `area_km2`, `location` (Point) | Une île de l'archipel.                                 |
| **`HydroplaneZone`** | `zone_code`, `name`, `type`, `location` (Point) | Un point d'atterrissage/port sur une île.              |

**Relations :**

* `(:Island)-[:HAS_ZONE]->(:HydroplaneZone)`

### 2\. MongoDB (Données Métier)

Stocke les informations transactionnelles et administratives.

| Collection | Champs Clés | Description |
| :--- | :--- | :--- |
| **`clients`** | `client_id`, `name`, `contact`, `home_port` (Lien vers `zone_code` Neo4j) | Scientifiques et clients à livrer. |
| **`products`** | `product_id`, `name`, `stock_total`, `crates_per_unit` | Matériel scientifique et son encombrement en caisses. |
| **`orders`** | `order_id`, `client_id`, `items`, `status` | Commandes en attente ou livrées. |
| **`lockers`** | `locker_id`, `port_id` (Lien vers `zone_code`), `is_empty` | Casiers de réception sur les ports. |
| **`hydravion_traces`** | `hydravion_id`, `lat`, `lon`, `fuel_level`, `timestamp` | Historique des positions pour le replay. |

-----

## 🚀 API GraphQL & Requêtes Principales

### Requêtes de Consultation (Queries)

* **`locateSeaplanes`** : Récupère la position, le statut et le niveau de carburant de tous les avions (Source : Neo4j).
* **`islands` / `zones`** : Récupère la topologie de la carte pour l'affichage (Source : Neo4j).
* **`inventory`** : Récupère les stocks produits et les commandes clients (Source : MongoDB).

### Algorithme d'Optimisation 
`optimizeDelivery`

**Signature :**

```graphql
query optimizeDelivery($seaplaneId: String!, $clientIds: [Int]!) { ... }
```

**Logique d'exécution (Resolver Hybride) :**

1.  **Contexte Avion (Neo4j) :** Récupère la capacité et la **position actuelle** (`Point`) de l'avion.
2.  **Ciblage (Mongo) :** Trouve les zones de livraison (`home_port`) des clients demandés.
3.  **Calcul de Charge (Mongo) :** Calcule le volume total en caisses (`crates_per_unit * quantity`) des commandes en attente.
4.  **Routing Géodésique (Neo4j) :** Calcule la distance réelle point-à-point :
    * *Départ :* Position actuelle de l'avion.
    * *Etapes :* Visite séquentielle des zones clients.
    * *Retour :* Retour à la position initiale de l'avion (boucle fermée).
5.  **Vérification de Faisabilité :**
    * Est-ce que `Carburant nécessaire <= Carburant avion` ?
    * Est-ce que `Caisses à livrer <= Capacité soute` ? 
6.  **Vérification Infrastructure (Mongo) :** Vérifie s'il y a assez de `Lockers` vides au port de destination. Si non, un **warning** est levé pour signaler une livraison partielle nécessaire.

-----

## 💻 Installation et Démarrage

### Prérequis

* Node.js (v16+)
* Une instance MongoDB (locale ou Atlas)
* Une instance Neo4j (Desktop ou AuraDB)

### 1\. Installation des dépendances

```bash
npm install
```

### 2\. Lancement du Serveur

```bash
node index.js
```

*Le serveur sera accessible sur `http://localhost:4000`.*

### 4\. Lancement de l'Interface

* Onglet **Carte** : Visualisation temps réel.
* Onglet **Planificateur** : Calcul de tournées.
* Onglet **Stock et Client** : Liste des client et des commandes.
* Onglet **Flotte** : État des avions.