from db import connect

connection = connect()
cursor = connection.cursor()

#TODO: resolve path from wherever we run script from rather than hardcoding path
with open("db/ddl.sql", "r") as file:
    cursor.execute(file.read())

connection.commit()

