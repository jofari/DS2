#lire article et le code qui permet tout betement de lire et de aficher un article 

def lire_article(conn ,version_modele, nbr): 
    
    REQUETE_A_CLASSER = """
    SELECT resume ,id , source,titre,brut
    FROM public.news n
    WHERE NOT EXISTS (
        select 1 from ds2.clasifications c 
        where c.version_modele=%s
            and c.article_id=n.id
    )
    order by n.ts_recu 
    LIMIT %s
    """
    with conn.cursor() as curs:
        curs.execute(REQUETE_A_CLASSER, (version_modele, nbr))
        articles=curs.fetchall()
    return articles