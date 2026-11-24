--Partie1 : Exploration des données
-- step 1
-- compte le nombre de clients:5000
SELECT COUNT(*) AS nombre_clients
FROM clients;
-- nombre de ventes: 15000
SELECT COUNT(*) AS nombre_ventes    
FROM ventes;

-- Le nombre de produits vendus: 200
SELECT COUNT(*) AS nombre_produits
FROM produits;

--nombre de paiements: 15000
SELECT COUNT(*) AS nombre_paiements 
FROM paiements;

-- step 2 afficher l'echantillon
select * 
from clients 
limit 10;

select * 
from ventes
 limit 10;  

select *
from produits
limit 10;

select *
from paiements
limit 10;   

-- step 3 : verifier les colonnes importantes
--les pays des clients
SELECT DISTINCT pays
FROM clients;   

--categories des produits
SELECT DISTINCT categorie
FROM produits;

-- Methode de paiement
SELECT DISTINCT methode   
FROM paiements;

-- step 4 : statistiques descriptives sur les ventes
select SUM(montant_total) as total_ventes,
       AVG(montant_total) as moyenne_ventes,
       MIN(montant_total) as vente_minimale,
       MAX(montant_total) as vente_maximale,
       SUM(montant_total*quantite) as CA
from ventes;

-- Partie2 : Nettoyage des données
-- step 1 : Les ventes avec les paiements reussis
SELECT v.*
FROM ventes v
JOIN paiements p ON v.id_vente = p.id_vente
WHERE p.statut = 'Success'
LIMIT 10;

-- Step 2 : Les doublons dans les ventes
SELECT id_vente, COUNT(*) AS nombre_occurrences
FROM ventes
GROUP BY id_vente
HAVING COUNT(*) > 1;

--les doublons dans les clients
SELECT id_client, COUNT(*) AS nombre_occurrences
FROM clients
GROUP BY id_client
HAVING COUNT(*) > 1;

-- doublons dans les produits
SELECT id_produit, COUNT(*) AS nombre_occurrences   
FROM produits
GROUP BY id_produit
HAVING COUNT(*) > 1;

-- doublons dans les paiements
SELECT id_paiement, COUNT(*) AS nombre_occurrences  
FROM paiements
GROUP BY id_paiement    
HAVING COUNT(*) > 1;


-- Step 3 : Les valeurs nulles et manquantes des clients
SELECT *
FROM clients
WHERE id_client IS NULL OR
      nom_client IS NULL OR 
      pays IS NULL OR 
      ville IS NULL OR 
      date_inscription IS NULL OR 
      canal_acquisition IS NULL;   
-- Step 4 : Les valeurs nulles et manquantes des produits
SELECT *
FROM produits   
WHERE id_produit IS NULL OR
      nom_produit IS NULL OR 
      categorie IS NULL OR 
      prix IS NULL;    

-- chiffre d'affaires
SELECT SUM(montant_total) AS chiffre_affaires
FROM ventes
JOIN paiements ON ventes.id_vente = paiements.id_vente
WHERE paiements.statut = 'Success';

-- chiffre d'affaires par mois
SELECT EXTRACT('month' FROM v.date_vente) AS mois,
       SUM(v.montant_total) AS chiffre_affaires
FROM ventes v
JOIN paiements p ON v.id_vente = p.id_vente
WHERE p.statut = 'Success'
GROUP BY mois
ORDER BY mois;
 
 -- chiffre d'affaire par jours de la semaine
SELECT 
      CASE EXTRACT('dow' FROM v.date_vente) 
           WHEN 0 THEN 'Dimanche'
           WHEN 1 THEN 'Lundi'
           WHEN 2 THEN 'Mardi'
           WHEN 3 THEN 'Mercredi'
           WHEN 4 THEN 'Jeudi'
           WHEN 5 THEN 'Vendredi'
           WHEN 6 THEN 'Samedi'
      END AS jour_semaine,
       SUM(v.montant_total) AS chiffre_affaires       
FROM ventes v
JOIN paiements p ON v.id_vente = p.id_vente
WHERE p.statut = 'Success'
GROUP BY jour_semaine
ORDER BY chiffre_affaires DESC;


-- Methode de paiement et nombre de vente et chiffre d'affaires par vente
SELECT p.methode, 
      COUNT(v.id_vente) AS nombre_ventes,
      SUM(v.montant_total) AS chiffre_affaires
FROM ventes v    
JOIN paiements p ON v.id_vente = p.id_vente
WHERE p.statut = 'Success'
GROUP BY p.methode
ORDER BY chiffre_affaires DESC;


-- Analyse des produits: best sellers, top 10 revenu, panier moyen par produit et produits faibles
-- Top 10 PRODUITS VENDUS EN VOLUME
SELECT p.nom_produit, 
       SUM(v.quantite) AS total_quantite_vendue,
       SUM(v.montant_total) AS chiffre_affaires
FROM ventes v
JOIN produits p ON v.id_produit = p.id_produit
JOIN paiements pmt ON v.id_vente = pmt.id_vente
WHERE pmt.statut = 'Success'
GROUP BY p.nom_produit
ORDER BY total_quantite_vendue DESC
LIMIT 10;

-- Panier moyen par produit et avec des paiements succès
SELECT p.nom_produit, 
       ROUND(AVG(v.montant_total),2) AS panier_moyen  
FROM ventes v
JOIN produits p ON v.id_produit = p.id_produit
JOIN paiements pmt ON v.id_vente = pmt.id_vente
WHERE pmt.statut = 'Success'
GROUP BY p.nom_produit
ORDER BY panier_moyen DESC;

-- Produits faibles en ventes et chiffre d'affaires
SELECT p.nom_produit, 
       SUM(v.quantite) AS total_quantite_vendue,
       SUM(v.montant_total) AS chiffre_affaires
FROM ventes v
JOIN produits p ON v.id_produit = p.id_produit
JOIN paiements pmt ON v.id_vente = pmt.id_vente
WHERE pmt.statut = 'Success'
GROUP BY p.nom_produit
ORDER BY total_quantite_vendue, chiffre_affaires ASC
LIMIT 10;   

-- Analyse des clients:
-- chiffre d'affaires par ville et pays
SELECT c.ville, c.pays, 
       SUM(v.montant_total) AS chiffre_affaires,
       COUNT(v.id_vente) AS nombre_ventes
FROM ventes v
JOIN clients c ON v.id_client = c.id_client
JOIN paiements p ON v.id_vente = p.id_vente
WHERE p.statut = 'Success'
GROUP BY c.ville, c.pays
ORDER BY nombre_ventes DESC
LIMIT 10;

-- RFM simplifier:
-- Client Récents: les clients qui ont acheté récemment
SELECT c.id_client, c.nom_client, MAX(v.date_vente) AS derniere_achat
FROM clients c
JOIN ventes v ON c.id_client = v.id_client
JOIN paiements p ON v.id_vente = p.id_vente
WHERE p.statut = 'Success'
GROUP BY c.id_client, c.nom_client
ORDER BY derniere_achat DESC
LIMIT 10;
-- Client Fréquent: les clients qui ont acheté le plus souvent
SELECT c.id_client, c.nom_client, COUNT(v.id_vente) AS nombre_achats
FROM clients c
JOIN ventes v ON c.id_client = v.id_client
JOIN paiements p ON v.id_vente = p.id_vente
WHERE p.statut = 'Success'
GROUP BY c.id_client, c.nom_client
ORDER BY nombre_achats DESC
LIMIT 10;
-- Client Monétaire: les clients qui ont dépensé le plus.
SELECT c.id_client, c.nom_client, SUM(v.montant_total) AS total_depense
FROM clients c
JOIN ventes v ON c.id_client = v.id_client
JOIN paiements p ON v.id_vente = p.id_vente
WHERE p.statut = 'Success'
GROUP BY c.id_client, c.nom_client
ORDER BY total_depense DESC
LIMIT 10;