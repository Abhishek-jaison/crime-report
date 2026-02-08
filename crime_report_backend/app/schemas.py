from pydantic import BaseModel, EmailStr

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

class User(UserBase):
    id: int
    is_active: bool = True

    class Config:
        orm_mode = True
