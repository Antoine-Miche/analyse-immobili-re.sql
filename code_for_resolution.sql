-- QUESTION 1

SELECT COUNT(vente.date_vente)AS nb_vente_premier_semestre
FROM vente
INNER JOIN bien_immobilier ON vente.id_bien = bien_immobilier.id_bien
WHERE bien_immobilier.type_de_local = 'Appartement' AND(vente.date_vente BETWEEN '2020-01-01' AND '2020-07-01');

-- QUESTION 2

SELECT region.id_region,
region.nom_region,
COUNT(vente.date_vente) AS nb_vente
FROM vente
INNER JOIN bien_immobilier ON vente.id_bien = bien_immobilier.id_bien
INNER JOIN commune ON bien_immobilier.id_commune = commune.id_commune
INNER JOIN region ON commune.id_region = region.id_region
WHERE (vente.date_vente BETWEEN '2020-01-01' AND '2020-07-01') AND bien_immobilier.type_de_local = 'Appartement'
GROUP BY region.nom_region, region.id_region
ORDER BY nb_vente DESC;

-- QUESTION 3

SELECT bien_immobilier.total_piece, 
       ROUND(COUNT(vente.date_vente) * 100.0 / (SELECT COUNT(vente.id_vente) FROM vente INNER JOIN bien_immobilier ON vente.id_bien = bien_immobilier.id_bien WHERE bien_immobilier.type_de_local = 'Appartement'), 2) AS pourcentage_de_vente
FROM bien_immobilier
INNER JOIN vente on bien_immobilier.id_bien = vente.id_bien
WHERE bien_immobilier.type_de_local = 'Appartement'
GROUP BY bien_immobilier.total_piece
ORDER BY bien_immobilier.total_piece;


-- QUESTION 4

SELECT 
commune.nom_departement,
commune.id_departement,
ROUND(AVG (vente.valeur/bien_immobilier.surface_carrez)) AS prix_metre_carre
FROM vente
INNER JOIN bien_immobilier on vente.id_bien = bien_immobilier.id_bien
INNER JOIN commune on bien_immobilier.id_commune = commune.id_commune
GROUP BY commune.nom_departement, commune.id_departement
ORDER BY prix_metre_carre DESC LIMIT 10;

-- QUESTION 5

SELECT 
bien_immobilier.type_de_local,
ROUND(AVG (vente.valeur/bien_immobilier.surface_carrez)) AS prix_metre_carre
FROM vente
INNER JOIN bien_immobilier on vente.id_bien = bien_immobilier.id_bien
INNER JOIN commune on bien_immobilier.id_commune = commune.id_commune
INNER JOIN region on commune.id_region = region.id_region
WHERE region.nom_region = 'Île-de-France' AND bien_immobilier.type_de_local = 'Maison'
GROUP BY bien_immobilier.type_de_local;

-- QUESTION 6

SELECT vente.date_vente,
vente.valeur,
region.nom_region,
commune.id_departement,
bien_immobilier.surface_carrez
FROM vente
INNER JOIN bien_immobilier ON vente.id_bien = bien_immobilier.id_bien
INNER JOIN commune ON bien_immobilier.id_commune = commune.id_commune
INNER JOIN region ON commune.id_region = region.id_region
WHERE bien_immobilier.type_de_local = 'Appartement' AND vente.valeur IS NOT NULL
ORDER BY vente.valeur DESC LIMIT 10;

-- QUESTION 7

WITH
vente1 AS (
SELECT round(count(vente.id_vente),2) AS nbventes1
FROM vente
WHERE vente.date_vente BETWEEN '2020-01-01' AND '2020-03-31'),
vente2 AS (
SELECT round(count(vente.id_vente),2) AS nbventes2
FROM vente
WHERE vente.date_vente BETWEEN '2020-04-01' AND '2020-06-30')
SELECT round(((nbventes2 - nbventes1) / nbventes1 * 100), 2) as taux_evolution
FROM vente1, vente2

-- QUESTION 8

SELECT region.nom_region,
ROUND(AVG (vente.valeur/bien_immobilier.surface_carrez)) AS prix_metre_carre

FROM vente
INNER JOIN bien_immobilier ON vente.id_bien = bien_immobilier.id_bien
INNER JOIN commune ON bien_immobilier.id_commune = commune.id_commune
INNER JOIN region ON commune.id_region = region.id_region
WHERE bien_immobilier.type_de_local = 'Appartement' AND bien_immobilier.total_piece >4
Group by region.nom_region
Order by prix_metre_carre DESC;

--QUESTION 9

SELECT commune.nom_commune,
COUNT(vente.id_vente) AS nb_vente
FROM 
vente
INNER JOIN bien_immobilier ON vente.id_bien = bien_immobilier.id_bien
INNER JOIN commune ON bien_immobilier.id_commune = commune.id_commune
WHERE vente.date_vente BETWEEN '2020-01-01' AND '2020-04-01'
GROUP BY commune.nom_commune
HAVING COUNT(vente.id_vente)>=50
ORDER BY commune.nom_commune;

-- QUESTION 10
WITH
piece2 AS (
SELECT avg(vente.valeur / bien_immobilier.surface_carrez) AS prixm2_2P
FROM vente
JOIN bien_immobilier USING (id_bien)
JOIN commune USING (id_commune)
WHERE bien_immobilier.type_de_local = 'Appartement' AND bien_immobilier.total_piece = 2),
piece3 AS (
SELECT avg(vente.valeur / bien_immobilier.surface_carrez) AS prixm2_3P
FROM vente
JOIN bien_immobilier USING (id_bien)
JOIN commune USING (id_commune)
WHERE bien_immobilier.type_de_local = 'Appartement' AND bien_immobilier.total_piece = 3)
SELECT ROUND((((SELECT prixm2_3P FROM piece3) - (SELECT prixm2_2P FROM piece2))*100/(SELECT prixm2_2P FROM piece2))) AS taux_evolution_prix_2P_3P;

--QUESTION 11

SELECT * FROM
(SELECT ROUND(AVG(vente.valeur)) as moyenne_valeur, ROW_NUMBER () OVER (PARTITION BY commune.id_departement ORDER BY AVG(vente.valeur) desc ) as classement,
 commune.nom_commune, commune.id_departement
 FROM commune
 INNER JOIN bien_immobilier on commune.id_commune = bien_immobilier.id_commune
 INNER JOIN vente on bien_immobilier.id_bien = vente.id_bien
 WHERE commune.id_departement in ('69', '6', '33', '59','13')
 GROUP BY commune.id_departement, commune.nom_commune
 ORDER BY commune.id_departement) ranks
 WHERE classement <= 3;


