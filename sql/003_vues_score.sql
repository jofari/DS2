-- Force : décile de la probabilité, vide pour neutral
CREATE VIEW ds2.v_force AS
SELECT
    article_id, actif, classe_actif, version_modele, sentiment, proba,
    CASE
        WHEN sentiment = 'neutral' THEN NULL
        ELSE ntile(10) OVER (PARTITION BY version_modele, sentiment ORDER BY proba)
    END AS force_sentiment
FROM ds2.clasifications;

-- Score par actif et par jour : sens × force × coefficient de la source
CREATE VIEW ds2.v_score_jour AS
SELECT
    f.actif,
    f.classe_actif,
    f.version_modele,
    date_trunc('day', n.ts_recu) AS jour,
    SUM(
        CASE f.sentiment WHEN 'bullish' THEN 1 WHEN 'bearish' THEN -1 ELSE 0 END
        * COALESCE(f.force_sentiment, 0)
        * c.coef
    ) AS score,         
    count(*) AS nb_articles
FROM ds2.v_force f
JOIN public.news n ON n.id = f.article_id
JOIN ds2.coef_source c
  ON c.source = n.source
 AND n.ts_recu >= c.date_debut
 AND (c.date_fin IS NULL OR n.ts_recu < c.date_fin)
GROUP BY f.actif, f.classe_actif, f.version_modele, jour;

-- Le pipeline doit pouvoir lire les vues
GRANT SELECT ON ds2.v_force, ds2.v_score_jour TO ds2_pipeline;

