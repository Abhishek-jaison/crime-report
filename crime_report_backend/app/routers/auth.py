from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Form
from sqlalchemy.orm import Session
from sqlalchemy import func
from .. import schemas, crud, utils, database, models
from ..utils_email import send_otp_email
from ..database import SessionLocal
from ..utils_cloudinary import upload_to_cloudinary

router = APIRouter(
    prefix="/auth",
    tags=["Authentication"]
)

# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/signup", response_model=schemas.User)
def signup(user: schemas.UserCreate, db: Session = Depends(get_db)):
    db_user = crud.get_user_by_email(db, email=user.email)
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    # OTP verification removed
    return crud.create_user(db=db, user=user)

@router.post("/login")
def login(user: schemas.UserLogin, db: Session = Depends(get_db)):
    print(f"DEBUG: Login attempt for email: '{user.email}'")
    db_user = crud.get_user_by_email(db, email=user.email)
    if not db_user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    if not utils.verify_password(user.password, db_user.hashed_password):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    return {
        "message": "Login successful",
        "user_id": db_user.id,
        "name": db_user.name,
        "email": db_user.email,
        "profile_pic": db_user.profile_pic,
    }

@router.post("/upload-profile-pic")
def upload_profile_pic(
    email: str = Form(...),
    file: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    """Upload a profile picture for a user. Returns the Cloudinary URL."""
    db_user = crud.get_user_by_email(db, email=email)
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")
    url = upload_to_cloudinary(file, resource_type="image")
    db_user.profile_pic = url
    db.commit()
    db.refresh(db_user)
    return {"profile_pic": url, "message": "Profile picture updated successfully"}

@router.get("/users", response_model=list[str])
def get_all_user_emails(db: Session = Depends(get_db)):
    users = db.query(models.User).all()
    return [user.email for user in users]

@router.get("/users/all", response_model=list[schemas.UserDetail])
def get_all_users_detail(db: Session = Depends(get_db)):
    """Return all registered users with their complaint counts."""
    results = (
        db.query(
            models.User,
            func.count(models.Complaint.id).label("complaint_count")
        )
        .outerjoin(models.Complaint, models.Complaint.user_email == models.User.email)
        .group_by(models.User.id)
        .order_by(models.User.id.desc())
        .all()
    )
    return [
        schemas.UserDetail(
            id=user.id,
            name=user.name,
            email=user.email,
            profile_pic=user.profile_pic,
            created_at=user.created_at,
            complaint_count=count,
        )
        for user, count in results
    ]
