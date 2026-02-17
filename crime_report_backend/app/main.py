from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
import os

from . import models
from .database import engine
from .routers import auth, complaints, debug, sos

# --------------------------------------------------
# CREATE FASTAPI APP
# --------------------------------------------------
app = FastAPI(title="Crime Reporting System API")

# --------------------------------------------------
# ENSURE UPLOADS DIRECTORY EXISTS (IMPORTANT FOR RENDER)
# --------------------------------------------------
UPLOAD_DIR = "uploads"

os.makedirs(UPLOAD_DIR, exist_ok=True)

# Mount static files so uploaded images/videos are accessible
app.mount("/static", StaticFiles(directory=UPLOAD_DIR), name="static")

# --------------------------------------------------
# CORS CONFIGURATION
# --------------------------------------------------
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for dev (React/Flutter)
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --------------------------------------------------
# DATABASE INITIALIZATION
# --------------------------------------------------
from sqlalchemy import inspect

# Check for existing tables (Persistence Verification)
inspector = inspect(engine)
existing_tables = inspector.get_table_names()

print(f"🔍 Database Dialect: {engine.dialect.name}")
print(f"🔍 Existing tables: {existing_tables}")

if not existing_tables:
    print("⚠️  No tables found. Creating schema...")

# Run create_all to ensure ANY missing tables (like sos_alerts) are created.
# This checks existence before creating, so perfectly safe.
models.Base.metadata.create_all(bind=engine)
print("✅ Schema verification/update complete.")

# --------------------------------------------------
# ROUTERS
# --------------------------------------------------
app.include_router(auth.router)
app.include_router(complaints.router)
app.include_router(debug.router)
app.include_router(sos.router)

# --------------------------------------------------
# ROOT ENDPOINT
# --------------------------------------------------
@app.get("/")
def root():
    return {"message": "Crime Reporting Backend is running"}
