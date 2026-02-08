from fastapi import FastAPI
from . import models
from .database import engine
from .routers import auth

models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="Crime Reporting System API")

app.include_router(auth.router)

@app.get("/")
def root():
    return {"message": "Crime Reporting Backend is running"}
