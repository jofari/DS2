import os
from dotenv import load_dotenv
import psycopg

def ouvrire_conect():
    load_dotenv()
    conn = psycopg.connect()
    return conn 


