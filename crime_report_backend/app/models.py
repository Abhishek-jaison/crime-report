from sqlalchemy import Boolean, Column, ForeignKey, Integer, String, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from .database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=True)
    email = Column(String, unique=True, index=True)
    aadhaar_number = Column(String, nullable=True) # Added field
    hashed_password = Column(String)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class OTP(Base):
    __tablename__ = "otps"

    email = Column(String, primary_key=True, index=True)
    otp = Column(String)
    expires_at = Column(DateTime(timezone=True))
    is_verified = Column(Boolean, default=False)

class Complaint(Base):
    __tablename__ = "complaints"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String)
    description = Column(String)
    crime_type = Column(String)
    user_email = Column(String, ForeignKey("users.email"))
    image_path = Column(String, nullable=True)
    video_path = Column(String, nullable=True)
    status = Column(String, default="Pending")
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
class SOSAlert(Base):
    __tablename__ = "sos_alerts"

    id = Column(Integer, primary_key=True, index=True)
    user_email = Column(String, nullable=True)
    lat = Column(String) # Storing as String for flexibility or Float
    long = Column(String) 
    created_at = Column(DateTime(timezone=True), server_default=func.now())
