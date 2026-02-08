from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from . import models
from .database import engine
from .routers import auth, complaints

models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="Crime Reporting System API")

app.mount("/static", StaticFiles(directory="uploads"), name="static")

app.include_router(auth.router)
app.include_router(complaints.router)

@app.get("/")
def root():
    return {"message": "Crime Reporting Backend is running"}
