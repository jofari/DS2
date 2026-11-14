# Notes d'environnement DS2 (poste Windows 11)

Environnement de développement uniquement. DS2 tournera sur le VPS Linux.

État au 08/11/2026 : étapes 1 à 4 terminées, `ds2_test` contient 50 lignes de news
et FinBERT fonctionne en CPU.

## Emplacements

| Élément | Chemin |
|---|---|
| Projet | `C:\Users\jofar\ds2` |
| Environnement virtuel | `C:\Users\jofar\ds2\.venv` |
| Paramètres de connexion et mot de passe | `C:\Users\jofar\ds2\.env` (ignoré par Git) |
| PostgreSQL 16.15 portable | `C:\Users\jofar\postgres16\pgsql` |
| Données PostgreSQL | `C:\Users\jofar\postgres16\data` |
| Journal PostgreSQL | `C:\Users\jofar\postgres16\postgres.log` |
| Cache FinBERT | `C:\Users\jofar\.cache\huggingface\hub\models--ProsusAI--finbert` |

## Versions installées

Python 3.14.2, torch 2.15.0+cpu, transformers 5.22.2, tokenizers 0.23.3,
psycopg 3.3.8, numpy 2.5.4, PostgreSQL 16.15.

L'égalité avec le VPS reste à vérifier au déploiement : ces versions ont été
choisies sans connaître celles du VPS.

## Usage quotidien

### Réactiver l'environnement virtuel

Dans PowerShell :

```powershell
cd C:\Users\jofar\ds2
.\.venv\Scripts\Activate.ps1
```

Si PowerShell bloque le script, autorise-le pour cette fenêtre seulement, puis relance l'activation :

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

Pour sortir de l'environnement : `deactivate`.

Hors du venv, `python` renvoie « introuvable » sur ce poste, car le raccourci du
Microsoft Store passe en premier dans le PATH. Utilise `py -3.14` dans ce cas.

### Démarrer et arrêter PostgreSQL

Le serveur n'est pas un service Windows : il ne redémarre pas seul après un
redémarrage du PC.

```powershell
# Démarrer le serveur
C:\Users\jofar\postgres16\pgsql\bin\pg_ctl.exe start -D C:\Users\jofar\postgres16\data -l C:\Users\jofar\postgres16\postgres.log -w

# Voir s'il tourne
C:\Users\jofar\postgres16\pgsql\bin\pg_ctl.exe status -D C:\Users\jofar\postgres16\data

# Arrêter le serveur
C:\Users\jofar\postgres16\pgsql\bin\pg_ctl.exe stop -D C:\Users\jofar\postgres16\data
```

## Se connecter à ds2_test

Paramètres : hôte `127.0.0.1`, port `5432`, base `ds2_test`, utilisateur
`postgres`. Le mot de passe se trouve dans `.env`.

Ni `psql` ni psycopg ne lisent `.env` tout seuls. Charge-le d'abord dans la
fenêtre PowerShell, depuis le dossier du projet :

```powershell
Get-Content .env | ForEach-Object { $k,$v = $_ -split '=',2; Set-Item "env:$k" $v }
```

Puis, avec `psql` :

```powershell
C:\Users\jofar\postgres16\pgsql\bin\psql.exe
```

Ou en Python, venv activé. Sans argument, psycopg utilise les variables `PG*` :

```python
import psycopg

with psycopg.connect() as conn:
    print(conn.execute("select current_database()").fetchone())
```

## Commandes exécutées pour l'installation

### Inspection (lecture seule)

| Commande | À quoi elle sert |
|---|---|
| `python --version`, `py -0p`, `Get-Command python -All` | Trouver les versions de Python et leur emplacement |
| `git --version` | Vérifier la présence de Git |
| `Get-Command psql`, `Get-Service *postgres*`, `Test-Path "C:\Program Files\PostgreSQL"` | Chercher un PostgreSQL existant |
| `Get-NetTCPConnection -LocalPort 5432` | Vérifier si le port de PostgreSQL est libre |
| `docker --version`, `docker info`, `Get-Service *docker*` | Vérifier la présence de Docker |
| `wsl --status`, `wsl -l -v` | Vérifier la présence de WSL |
| `Get-PSDrive`, `Get-CimInstance Win32_ComputerSystem` | Mesurer l'espace disque et la RAM |
| `Get-CimInstance Win32_Processor` | Vérifier l'indicateur de virtualisation du BIOS |
| `Get-ChildItem C:\Users\jofar\venvs -Recurse -Filter pg_ctl.exe` | Trouver le PostgreSQL embarqué dans le venv de DS1 |
| `winget --version` | Vérifier la présence de winget |
| `Invoke-WebRequest https://download.pytorch.org/whl/cpu/torch/` | Lister les versions CPU de torch par version de Python |

### Projet

| Commande | À quoi elle sert |
|---|---|
| `New-Item -ItemType Directory -Force C:\Users\jofar\ds2\export` | Créer le projet et le dossier `export/` |
| `git -C C:\Users\jofar\ds2 init` | Initialiser le dépôt Git |
| Écriture de `.gitignore` (`.venv/`, `.env`, `export/`, `__pycache__/`) | Exclure ces éléments de Git |
| `py -3.14 -m venv C:\Users\jofar\ds2\.venv` | Créer l'environnement virtuel |

### Paquets Python

| Commande | À quoi elle sert |
|---|---|
| `python -m pip install "psycopg[binary]" transformers` | Installer le pilote PostgreSQL et la bibliothèque de modèles |
| `python -m pip install torch --index-url https://download.pytorch.org/whl/cpu` | Installer torch en version CPU |
| `python -m pip check` | Vérifier l'absence de conflit entre paquets |

### PostgreSQL

Le mot de passe n'apparaît pas dans ces commandes. `initdb` l'a lu dans un fichier
temporaire, supprimé juste après.

| Commande | À quoi elle sert |
|---|---|
| `Invoke-WebRequest -Method Head <url de l'archive>` | Trouver la dernière archive 16.x et sa taille |
| `curl.exe -sS -L --fail -o <zip> https://get.enterprisedb.com/postgresql/postgresql-16.15-1-windows-x64-binaries.zip` | Télécharger l'archive dans `postgres16\download` |
| `Get-FileHash <zip> -Algorithm SHA256` | Calculer l'empreinte de l'archive |
| `tar.exe -xf <zip> -C C:\Users\jofar\postgres16` | Extraire les programmes |
| `Get-AuthenticodeSignature pg_ctl.exe` | Vérifier la signature de l'éditeur (résultat : non signé) |
| `initdb -D <data> -U postgres --pwfile=<fichier temporaire> --auth-host=scram-sha-256 --auth-local=scram-sha-256 -E UTF8 --no-locale -c listen_addresses=localhost` | Créer le dossier de données, avec mot de passe obligatoire et écoute locale seulement |
| `pg_ctl start -D <data> -l <journal> -w -t 60` | Démarrer le serveur |
| `createdb ds2_test` | Créer la base de test |
| `psql -Atc "SELECT ..."` | Vérifier la version, l'encodage et le fuseau |

SHA-256 de l'archive :
`25E6FCDFB8CAEC38691BF461125E7564508760666F7B8E5DC6A5F0818F58F81E`

### Import de l'échantillon

Avant d'utiliser `psql`, charge `.env` comme indiqué plus haut, puis ajoute
`$env:PGCLIENTENCODING="UTF8"` pour éviter que `psql` suive l'encodage de la console.

| Commande | À quoi elle sert |
|---|---|
| `scp -o BatchMode=yes -o ConnectTimeout=20 "<utilisateur>@<ip_du_vps>:/opt/ds2/export/*" C:\Users\jofar\ds2\export` | Copier les fichiers du VPS sans demande de mot de passe |
| Copie de `news_structure.sql` vers `news_structure_local.sql`, sans la ligne `ALTER TABLE public.news OWNER TO ds1;` | Retirer la dépendance au rôle `ds1`, absent en local |
| `psql -v ON_ERROR_STOP=1 -q -f export\news_structure_local.sql` | Créer la table, ses contraintes et ses index |
| `psql -v ON_ERROR_STOP=1 -c "\copy public.news (id,ts_recu,ts_source,source,url,titre,resume,html_brut,texte,statut_page,brut) FROM 'C:/Users/jofar/ds2/export/news_echantillon.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')"` | Importer le CSV |
| `psql -Atc "SELECT setval('public.news_id_seq', (SELECT max(id) FROM public.news));"` | Recaler la séquence des `id`, que `COPY` n'avance pas |
| `python -I -c "import csv..."` | Recompter les lignes du CSV sans passer par PostgreSQL |
| `psql -c "SELECT source, count(*) ... GROUP BY source"` | Vérifier la répartition par source et la qualité du contenu |

Résultat : 50 lignes dans 13 sources. Aucun élément TimescaleDB dans la structure.
Les colonnes absentes du CSV ont pris leur valeur par défaut : `page_essais` = 0
et `page_ts` = NULL.

### Fuseau de la base

| Commande | À quoi elle sert |
|---|---|
| `psql -c "ALTER DATABASE ds2_test SET timezone TO 'UTC';"` | Mettre UTC par défaut pour les connexions à `ds2_test` |

### Test de FinBERT

Le test a été lancé avec un script temporaire, hors du projet, en utilisant le
Python du venv avec l'option `-I`. Il charge le modèle, compare les poids à
l'empreinte publiée par Hugging Face, puis classe 3 phrases.

Révision utilisée : `0bc2ac10dda6929bcb1f77ccc43c7ec5c424f031`

SHA-256 de `model.safetensors` :
`e5897858ff819aad7629b96ce521ae5477952d03634ef5dd30ed2d76357a9f00`

Le modèle était déjà en cache depuis le 05/11/2026 : ce test ne l'a pas téléchargé.

Pour reproduire la classification, venv activé :

```python
from transformers import pipeline

clf = pipeline(
    "text-classification",
    model="ProsusAI/finbert",
    revision="0bc2ac10dda6929bcb1f77ccc43c7ec5c424f031",
    device=-1,
)
print(clf(["The company reported record profits and raised its full-year guidance."]))
```

Forme du résultat par défaut : une liste avec un dictionnaire par phrase, qui
contient seulement la meilleure classe.

```python
[{'label': 'positive', 'score': 0.9533023834228516}]
```

Avec `top_k=None` : une liste de listes, avec les trois classes triées par score
décroissant pour chaque phrase.

## Différences à garder en tête avec le VPS

- Pas de TimescaleDB en local.
- Table `news` détenue par `postgres`, et non par `ds1`.
- Base créée avec `--no-locale` : le tri des textes suit l'ordre des octets, ce
  qui peut différer du VPS.
- Fuseau de `ds2_test` : `UTC`, réglé avec
  `ALTER DATABASE ds2_test SET timezone TO 'UTC';`. Les autres bases du serveur
  local restent en `Europe/Paris`.
