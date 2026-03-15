"""
Migration: Add 'profile_pic' column to users table in PostgreSQL.
Run once from the crime_report_backend directory.
"""
import os
from dotenv import load_dotenv
import psycopg2
from urllib.parse import urlparse

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    print("ERROR: DATABASE_URL not found in .env")
    exit(1)

print("Connecting to PostgreSQL...")

result = urlparse(DATABASE_URL)
conn = psycopg2.connect(
    dbname=result.path[1:],
    user=result.username,
    password=result.password,
    host=result.hostname,
    port=result.port,
    sslmode="require"
)
cursor = conn.cursor()

cursor.execute("""
    SELECT column_name FROM information_schema.columns
    WHERE table_name='users' AND column_name='profile_pic'
""")
exists = cursor.fetchone()

if not exists:
    print("Adding 'profile_pic' column...")
    cursor.execute("ALTER TABLE users ADD COLUMN profile_pic VARCHAR")
    conn.commit()
    print("Success: 'profile_pic' column added.")
else:
    print("Info: 'profile_pic' column already exists.")

cursor.close()
conn.close()
print("Done.")
