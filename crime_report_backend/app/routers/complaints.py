from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Form
from sqlalchemy.orm import Session
from .. import schemas, models, database, crud
from sqlalchemy import func
from datetime import datetime, timedelta, timezone
import shutil
import os
import uuid

router = APIRouter(
    prefix="/complaints",
    tags=["Complaints"],
)



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

    from ..utils_cloudinary import upload_to_cloudinary

    if image:
        print(f"DEBUG: Uploading image to Cloudinary...")
        image_path = upload_to_cloudinary(image, resource_type="image")
        print(f"DEBUG: Image uploaded: {image_path}")
    
    if video:
        print(f"DEBUG: Uploading video to Cloudinary...")
        video_path = upload_to_cloudinary(video, resource_type="video")
        print(f"DEBUG: Video uploaded: {video_path}")

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

@router.get("/stats")
def get_complaint_stats(db: Session = Depends(database.get_db)):
    """
    Get total complaints and today's complaints count.
    """
    # Use 24h window for "Today" stats (rolling window)
    total_complaints = db.query(models.Complaint).count()
    cutoff = datetime.now(timezone.utc) - timedelta(hours=24)
    
    today_complaints = db.query(models.Complaint).filter(
        models.Complaint.created_at >= cutoff
    ).count()
    
    return {
        "total_complaints": total_complaints,
        "today_complaints": today_complaints
    }

@router.get("/recent", response_model=list[schemas.Complaint])
def get_recent_complaints(limit: int = 5, db: Session = Depends(database.get_db)):
    """
    Get the most recent complaints.
    """
    return db.query(models.Complaint).order_by(models.Complaint.created_at.desc()).limit(limit).all()
