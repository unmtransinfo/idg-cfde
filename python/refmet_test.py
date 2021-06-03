#!/usr/bin/env python3

import sys,os,io,base64
import pandas as pd
import psycopg2,psycopg2.extras

DBHOST = "localhost"
DBPORT = 5432
DBNAME = "refmet"
DBUSR = "www"
DBPW = "foobar"

dsn = (f"host='{DBHOST}' port='{DBPORT}' dbname='{DBNAME}' user='{DBUSR}' password='{DBPW}'")
dbcon = psycopg2.connect(dsn)
#dbcon.cursor_factory = psycopg2.extras.DictCursor

rowcount = pd.read_sql("SELECT COUNT(*) FROM main", dbcon)
rowcount.to_csv(sys.stdout, "\t", index=False)
