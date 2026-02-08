from sqlalchemy.orm import Session
from . import models, schemas, utils

def get_user_by_email(db: Session, email: str):
    return db.query(models.User).filter(models.User.email == email).first()

def create_user(db: Session, user: schemas.UserCreate):
    hashed_password = utils.get_password_hash(user.password)
    db_user = models.User(
        email=user.email, 
        hashed_password=hashed_password,
        aadhaar_number=user.aadhaar_number
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

import random
import datetime

def create_otp(db: Session, email: str):
    otp = str(random.randint(100000, 999999))
    # 5 minutes expiry
    expires_at = datetime.datetime.utcnow() + datetime.timedelta(minutes=5)
    
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
        
    if db_otp.expires_at < datetime.datetime.utcnow():
        return False
        
    db_otp.is_verified = True
    db.commit()
    return True

def is_email_verified(db: Session, email: str):
    db_otp = db.query(models.OTP).filter(models.OTP.email == email).first()
    if not db_otp:
        return False
    return db_otp.is_verified
