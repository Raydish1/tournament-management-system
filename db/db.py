import psycopg

#TODO: move to env vars
def connect():
    connection = psycopg.connect(host="localhost", port=5432, dbname="tournament", user="admin", password="admin")
    return connection



