from sqlalchemy.orm import Session
from . import models, schemas, utils

def get_user_by_email(db: Session, email: str):
    email = email.strip()
    # Try exact match
    user = db.query(models.User).filter(models.User.email == email).first()
    if user:
        return user
        
    # Try case-insensitive
    from sqlalchemy import func
    return db.query(models.User).filter(func.lower(models.User.email) == email.lower()).first()

def create_user(db: Session, user: schemas.UserCreate):
    hashed_password = utils.get_password_hash(user.password)
    db_user = models.User(
        email=user.email, 
        hashed_password=hashed_password,
        aadhaar_number=user.aadhaar_number,
        name=user.name
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def get_user_complaints(db: Session, user_email: str):
    return db.query(models.Complaint).filter(models.Complaint.user_email == user_email).all()

import random
import datetime

def create_otp(db: Session, email: str, fixed_otp: str = None):
    if fixed_otp:
        otp = fixed_otp
    else:
        otp = str(random.randint(10000, 99999))
    # 5 minutes expiry (Timezone Aware)
    expires_at = datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(minutes=5)
    
    db_otp = db.query(models.OTP).filter(models.OTP.email == email).first()
    if db_otp:
        db_otp.otp = otp
        db_otp.expires_at = expires_at
        db_otp.is_verified = False
    else:
        db_otp = models.OTP(email=email, otp=otp, expires_at=expires_at)
        db.add(db_otp)
    
    db.commit()
    db.refresh(db_otp)
    return db_otp.otp

def verify_otp(db: Session, email: str, otp: str):
    db_otp = db.query(models.OTP).filter(models.OTP.email == email).first()
    if not db_otp:
        return False
    
    if db_otp.otp != otp:
        return False
        
    # Ensure comparison is timezone-aware
    now = datetime.datetime.now(datetime.timezone.utc)
    
    # Handle case where DB might return naive time (SQLite) vs Aware (Postgres)
    expires_at = db_otp.expires_at
    if expires_at.tzinfo is None:
        # If DB time is naive, assume it is UTC and make it aware
        expires_at = expires_at.replace(tzinfo=datetime.timezone.utc)
        
    if expires_at < now:
        return False
        
    db_otp.is_verified = True
    db.commit()
    return True

def is_email_verified(db: Session, email: str):
    db_otp = db.query(models.OTP).filter(models.OTP.email == email).first()
    if not db_otp:
        return False
    return db_otp.is_verified
