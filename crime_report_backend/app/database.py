from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

import os
from dotenv import load_dotenv

load_dotenv()

# Use env var or fallback to sqlite
SQLALCHEMY_DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./crime_report.db")

# DIAGNOSTIC: Print masked DB URL
if "sqlite" in SQLALCHEMY_DATABASE_URL:
    print(f"✅ Connected DB: SQLite ({SQLALCHEMY_DATABASE_URL})")
else:
    # Mask password for safety
    try:
        url_parts = SQLALCHEMY_DATABASE_URL.split("@")
        if len(url_parts) > 1:
            masked_url = f"{url_parts[0].split(':')[0]}:***@{url_parts[1]}"
            print(f"✅ Connected DB: {masked_url}")
        else:
            print(f"✅ Connected DB: {SQLALCHEMY_DATABASE_URL}") # Fallback if format differs
    except Exception:
        print("✅ Connected DB: PostgreSQL (URL masked)")

connect_args = {}
if "sqlite" in SQLALCHEMY_DATABASE_URL:
    connect_args = {"check_same_thread": False}

engine = create_engine(
    SQLALCHEMY_DATABASE_URL, connect_args=connect_args
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
