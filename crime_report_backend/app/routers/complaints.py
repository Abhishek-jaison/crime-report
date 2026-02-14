from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Form
from sqlalchemy.orm import Session
from .. import schemas, models, database, crud
import shutil
import os
import uuid

router = APIRouter(
    prefix="/complaints",
    tags=["Complaints"],
)

UPLOAD_DIR = "uploads"
IMAGE_DIR = os.path.join(UPLOAD_DIR, "images")
VIDEO_DIR = os.path.join(UPLOAD_DIR, "videos")

# Ensure directories exist
os.makedirs(IMAGE_DIR, exist_ok=True)
os.makedirs(VIDEO_DIR, exist_ok=True)

def save_file(file: UploadFile, directory: str) -> str:
    # Generate unique filename
    file_extension = os.path.splitext(file.filename)[1]
    unique_filename = f"{uuid.uuid4()}{file_extension}"
    file_path = os.path.join(directory, unique_filename)
    
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
        
    return file_path

@router.post("/", response_model=schemas.Complaint)
def create_complaint(
    title: str = Form(...),
    description: str = Form(...),
    crime_type: str = Form(...),
    user_email: str = Form(...),
    image: UploadFile = File(None),
    video: UploadFile = File(None),
    db: Session = Depends(database.get_db)
):
    # Robust lookup using CRUD
    user = crud.get_user_by_email(db, email=user_email)
    
    if not user:
        print(f"DEBUG: User not found for email: '{user_email}'")
        # Print all emails to help debug
        all_emails = [u.email for u in db.query(models.User).all()]
        print(f"DEBUG: Available emails: {all_emails}")
        raise HTTPException(status_code=404, detail=f"User not found for {user_email}")

    image_path = None
    video_path = None

    if image:
        image_path = save_file(image, IMAGE_DIR)
    
    if video:
        video_path = save_file(video, VIDEO_DIR)

    new_complaint = models.Complaint(
        title=title,
        description=description,
        crime_type=crime_type,
        user_email=user_email,
        image_path=image_path,
        video_path=video_path,
        status="Pending"
    )
    
    db.add(new_complaint)
    db.commit()
    db.refresh(new_complaint)
    
    return new_complaint

@router.get("/my-complaints", response_model=list[schemas.Complaint])
def get_my_complaints(user_email: str, db: Session = Depends(database.get_db)):
    # Verify user exists
    # Verify user exists (Robust)
    user = crud.get_user_by_email(db, email=user_email)
    if not user:
         raise HTTPException(status_code=404, detail="User not found")
         
    return crud.get_user_complaints(db=db, user_email=user_email)
