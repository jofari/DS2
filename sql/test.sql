-- Test 1 : une ligne valide → INSERT 0 1
INSERT INTO ds2.clasifications
  (article_id, sentiment, actif, version_modele, date_class, proba, texte_utilise, classe_actif, modele)
VALUES
  ((SELECT min(id) FROM public.news), 'bullish', 'BTC', 'test-v1', now(), 0.91, 'titre', 'crypto', 'finbert');

-- Test 2 : relance exactement le test 1
-- → ERROR: duplicate key value violates unique constraint

-- Test 3 : faute de frappe dans le sentiment → ERROR: ... violates check constraint
INSERT INTO ds2.clasifications
  (article_id, sentiment, actif, version_modele, date_class, proba, texte_utilise, classe_actif, modele)
VALUES
  ((SELECT min(id) FROM public.news), 'BULISH', 'ETH', 'test-v1', now(), 0.91, 'titre', 'crypto', 'finbert');

-- Test 4 : probabilité impossible → ERROR: ... violates check constraint
INSERT INTO ds2.clasifications
  (article_id, sentiment, actif, version_modele, date_class, proba, texte_utilise, classe_actif, modele)
VALUES
  ((SELECT min(id) FROM public.news), 'bullish', 'ETH', 'test-v1', now(), 1.5, 'titre', 'crypto', 'finbert');

-- Test 5 : article qui n'existe pas → ERROR: ... violates foreign key constraint
INSERT INTO ds2.clasifications
  (article_id, sentiment, actif, version_modele, date_class, proba, texte_utilise, classe_actif, modele)
VALUES
  (-1, 'bullish', 'ETH', 'test-v1', now(), 0.91, 'titre', 'crypto', 'finbert');

-- Test 6 : même article, même actif, autre version → INSERT 0 1
INSERT INTO ds2.clasifications
  (article_id, sentiment, actif, version_modele, date_class, proba, texte_utilise, classe_actif, modele)
VALUES
  ((SELECT min(id) FROM public.news), 'bearish', 'BTC', 'test-v2', now(), 0.80, 'titre', 'crypto', 'finbert');

-- Test 7 : coefficient négatif → ERROR: ... violates check constraint
INSERT INTO ds2.coef_source (source, coef, date_debut)
VALUES ('source_test', -1, DATE '2026-11-01');

-- Test 8 : date de fin avant la date de début → ERROR: ... violates check constraint
INSERT INTO ds2.coef_source (source, coef, date_debut, date_fin)
VALUES ('source_test', 1, DATE '2026-11-01', DATE '2026-10-01');