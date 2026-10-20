from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from datetime import datetime
from app.models.user import UserRole

# US-007: Đăng ký tài khoản Email / Phone
class UserRegisterRequest(BaseModel):
    email: Optional[EmailStr] = None
    phone: Optional[str] = None
    password: str = Field(..., min_length=6, description="Mật khẩu tối thiểu 6 ký tự")
    full_name: str = Field(..., min_length=2, max_length=150)
    location_city: Optional[str] = "TP. Hồ Chí Minh"

# Đăng nhập thông thường
class UserLoginRequest(BaseModel):
    identifier: str = Field(..., description="Email hoặc Số điện thoại")
    password: str

# US-008: Đăng nhập Google / Apple
class OAuthLoginRequest(BaseModel):
    provider: str = Field(..., description="'google' hoặc 'apple'")
    id_token: str
    email: Optional[EmailStr] = None
    full_name: Optional[str] = None
    avatar_url: Optional[str] = None

# US-009: Quên mật khẩu & OTP
class ForgotPasswordRequest(BaseModel):
    email: EmailStr

class ResetPasswordOTPRequest(BaseModel):
    email: EmailStr
    otp_code: str = Field(..., min_length=6, max_length=6)
    new_password: str = Field(..., min_length=6)

# US-010: Cập nhật thông tin cá nhân
class UserUpdateRequest(BaseModel):
    full_name: Optional[str] = None
    avatar_url: Optional[str] = None
    location_city: Optional[str] = None
    fcm_token: Optional[str] = None

# US-011: Xác thực Sinh trắc học
class BiometricEnableRequest(BaseModel):
    biometric_public_key: str

class BiometricLoginRequest(BaseModel):
    user_id: str
    signed_challenge: str

# US-012: Đổi mật khẩu định kỳ
class ChangePasswordRequest(BaseModel):
    old_password: str
    new_password: str = Field(..., min_length=6)

# US-013: Xóa vĩnh viễn tài khoản (Tiêu chuẩn CH Play)
class DeleteAccountRequest(BaseModel):
    confirm_text: str = Field(..., description="Người dùng gõ 'XOA TAI KHOAN' để xác nhận")
    password: Optional[str] = None

# US-014: Phân quyền người dùng
class RoleUpdateRequest(BaseModel):
    role: UserRole

# US-015: Khóa / Kích hoạt tài khoản
class UserStatusUpdateRequest(BaseModel):
    is_active: bool
    reason: Optional[str] = None

# Response DTOs
class UserResponse(BaseModel):
    id: str
    email: Optional[str] = None
    phone: Optional[str] = None
    full_name: str
    avatar_url: Optional[str] = None
    location_city: str
    role: UserRole
    is_active: bool
    is_biometric_enabled: bool
    last_password_changed_at: Optional[datetime] = None
    created_at: datetime

    class Config:
        from_attributes = True

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserResponse
