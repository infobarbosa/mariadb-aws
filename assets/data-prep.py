#!/usr/bin/python3
import pandas as pd
import datetime
import pymysql
import random
from pathlib import Path
from sqlalchemy import create_engine

datatypes = {
    "InvoiceNo": str,
    "StockCode": str,
    "Description": str,
    "Quantity": "Int64",
    "UnitPrice": float,
    "CustomerID": "Int64",
    "Country" : str
}

df = pd.read_csv('data.csv', encoding_errors='ignore', dtype = datatypes, parse_dates=['InvoiceDate'])

# Manipulando as datas originais para hoje
df['InvoiceDate'] = df["InvoiceDate"].map( \
    lambda d: datetime.datetime.now() - datetime.timedelta(seconds=random.randint(1, 600))
)

print( "### DESCRIBE ###" )
print( df.describe() )

print("### HEAD ###")
print( df.head() )

print( "### Abrindo conexão ###")
conn_string = 'mysql+pymysql://barbosa:BarbosaSenhaSuperSecreta@localhost/infobarbankdb'

db = create_engine(conn_string)
db = db.execution_options(autocommit=True)
conn = db.connect()

print( "### Conexão aberta ###")

df.to_csv("/tmp/faturamento.csv", index=None, date_format='%Y-%m-%d %H:%M:%S', columns=["InvoiceDate","Country","InvoiceNo","StockCode","Description","CustomerID","Quantity","UnitPrice"])

df.to_sql('pedido', con=conn, if_exists='replace', index=False)
print( "### Dados salvos ###")
