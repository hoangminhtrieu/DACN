from datetime import datetime, timedelta
from typing import Optional, Any, Union
import random
import string
import hashlib
from jose import jwt
from passlib.context import CryptContext
from app.core.config import settings

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

import bcrypt

def verify_password(plain_password: str, hashed_password: str) -> bool:
    try:
        return bcrypt.checkpw(plain_password.encode('utf-8')[:72], hashed_password.encode('utf-8'))
    except Exception:
        return False

def get_password_hash(password: str) -> str:
    return bcrypt.hashpw(password.encode('utf-8')[:72], bcrypt.gensalt()).decode('utf-8')

def create_access_token(subject: Union[str, Any], expires_delta: Optional[timedelta] = None) -> str:
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode = {"exp": expire, "sub": str(subject)}
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
    return encoded_jwt

def generate_numeric_otp(length: int = 6) -> str:
    """Sinh mã OTP 6 chữ số ngẫu nhiên cho quên mật khẩu (US-009)"""
    return "".join(random.choices(string.digits, k=length))

def generate_biometric_challenge() -> str:
    """Sinh chuỗi challenge ngẫu nhiên để xác thực sinh trắc học vân tay/FaceID (US-011)"""
    raw_str = "".join(random.choices(string.ascii_letters + string.digits, k=32))
    return hashlib.sha256(raw_str.encode()).hexdigest()
