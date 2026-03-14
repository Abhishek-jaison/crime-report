"""
Migration: Add 'status' column to sos_alerts table in PostgreSQL.
Run this once from the crime_report_backend directory with venv activated.
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

print(f"Connecting to PostgreSQL...")

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

# Check if column exists
cursor.execute("""
    SELECT column_name FROM information_schema.columns
    WHERE table_name='sos_alerts' AND column_name='status'
""")
exists = cursor.fetchone()

if not exists:
    print("Adding 'status' column...")
    cursor.execute("ALTER TABLE sos_alerts ADD COLUMN status VARCHAR NOT NULL DEFAULT 'Pending'")
    conn.commit()
    print("Success: 'status' column added with default 'Pending'.")
else:
    print("Info: 'status' column already exists.")

cursor.close()
conn.close()
print("Done.")
