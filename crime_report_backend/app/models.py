from sqlalchemy import Boolean, Column, ForeignKey, Integer, String, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from .database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    aadhaar_number = Column(String, nullable=True) # Added field
    hashed_password = Column(String)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
