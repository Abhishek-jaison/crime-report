from pydantic import BaseModel, EmailStr
from datetime import datetime

class UserBase(BaseModel):
    email: EmailStr

class UserCreate(UserBase):
    name: str | None = None
    password: str
    aadhaar_number: str | None = None
    phone_number: str | None = None

class UserLogin(UserBase):
    password: str

class OTPRequest(BaseModel):
    email: EmailStr

class OTPVerify(BaseModel):
    email: EmailStr
    otp: str

class Complaint(BaseModel):
    id: int
    title: str
    description: str
    crime_type: str
    user_email: str
    image_path: str | None = None
    video_path: str | None = None
    audio_path: str | None = None
    lat: str | None = None
    long: str | None = None
    suspect_details: str | None = None
    status: str
    created_at: datetime

    class Config:
        from_attributes = True

class User(UserBase):
    id: int
    name: str | None = None
    is_active: bool = True

    class Config:
        orm_mode = True

class UserDetail(BaseModel):
    id: int
    name: str | None = None
    email: str
    profile_pic: str | None = None
    phone_number: str | None = None
    created_at: datetime
    complaint_count: int = 0

    class Config:
        from_attributes = True

class SOSAlertBase(BaseModel):
    user_email: EmailStr | None = None
    lat: str
    long: str
    status: str = "Pending"

class SOSAlertCreate(SOSAlertBase):
    pass

class SOSAlert(SOSAlertBase):
    id: int
    created_at: datetime
    
    class Config:
        from_attributes = True
