from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from .. import schemas, crud, utils, database
from ..utils_email import send_otp_email
from ..database import SessionLocal

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

@router.post("/send-otp")
def send_otp(request: schemas.OTPRequest, db: Session = Depends(get_db)):
    # Check if user already exists
    db_user = crud.get_user_by_email(db, email=request.email)
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
        
    otp = crud.create_otp(db=db, email=request.email, fixed_otp="00000")
    
    # BYPASS EMAIL SENDING for Render reliability
    # if send_otp_email(request.email, otp):
    #     return {"message": "OTP sent successfully"}
    # else:
    #     raise HTTPException(status_code=500, detail="Failed to send email")
    return {"message": "OTP sent successfully (Bypassed: 00000)"}

@router.post("/verify-otp")
def verify_otp(request: schemas.OTPVerify, db: Session = Depends(get_db)):
    if crud.verify_otp(db=db, email=request.email, otp=request.otp):
        return {"message": "Email verified successfully"}
    else:
        raise HTTPException(status_code=400, detail="Invalid or expired OTP")

@router.post("/signup", response_model=schemas.User)
def signup(user: schemas.UserCreate, db: Session = Depends(get_db)):
    # 1. Check if user already exists
    db_user = crud.get_user_by_email(db, email=user.email)
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
        
    # 2. Check if email is verified
    if not crud.is_email_verified(db, user.email):
         raise HTTPException(status_code=400, detail="Email not verified. Please verify OTP first.")
         
    return crud.create_user(db=db, user=user)

@router.post("/login")
def login(user: schemas.UserLogin, db: Session = Depends(get_db)):
    db_user = crud.get_user_by_email(db, email=user.email)
    if not db_user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    
    if not utils.verify_password(user.password, db_user.hashed_password):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
        
    return {
        "message": "Login successful", 
        "user_id": db_user.id,
        "name": db_user.name,
        "email": db_user.email
    }
