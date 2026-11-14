from conect import ouvrire_conect
from lire_article import lire_article

if __name__ == "__main__":
    conn = ouvrire_conect()                              # ouvrir la connexion
    articles = lire_article(conn, "finbert-mvp", 3)    # lire 3 articles
    print(len(articles))
    print(articles[0])
    conn.close()