create schema DS2;

create table DS2.coef_source(
    source text NOT NULL,
    coef numeric NOT NULL check (coef>=0),
    date_debut date not null,
    date_fin date check(date_fin > date_debut),
    PRIMARY KEY (source,date_debut)
);

create table DS2.clasifications(
    article_id bigint not null REFERENCES public.news(id),
    sentiment text not null check (sentiment in('bullish','bearish','neutral')),
    actif text not null,
    version_modele text not null,
    date_class timestamptz not null default now(),
    proba numeric not null check(proba >= 0 and proba <=1),
    texte_utilise text not null,
    classe_actif text not null,
    modele text not null,
    unique (article_id,actif,version_modele)
);

create role ds2_pipeline login;
GRANT USAGE ON SCHEMA public TO ds2_pipeline;
GRANT USAGE ON SCHEMA ds2 TO ds2_pipeline;
GRANT SELECT ON public.news TO ds2_pipeline;
GRANT SELECT, INSERT ON ALL TABLES IN SCHEMA ds2 TO ds2_pipeline;
