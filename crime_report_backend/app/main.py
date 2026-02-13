from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
import os

from . import models
from .database import engine
from .routers import auth, complaints

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
# DATABASE INITIALIZATION
# --------------------------------------------------
models.Base.metadata.create_all(bind=engine)

# --------------------------------------------------
# ROUTERS
# --------------------------------------------------
app.include_router(auth.router)
app.include_router(complaints.router)

# --------------------------------------------------
# ROOT ENDPOINT
# --------------------------------------------------
@app.get("/")
def root():
    return {"message": "Crime Reporting Backend is running"}
