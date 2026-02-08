from pydantic import BaseModel, EmailStr
from datetime import datetime

class UserBase(BaseModel):
    email: EmailStr

class UserCreate(UserBase):
    password: str
    aadhaar_number: str | None = None

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
    status: str
    created_at: datetime

    class Config:
        from_attributes = True

class User(UserBase):
    id: int
    is_active: bool = True

    class Config:
        orm_mode = True
