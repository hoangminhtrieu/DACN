from datetime import datetime, timedelta
from typing import Optional, Tuple
from fastapi import HTTPException, status
from app.models.user import User, PasswordResetOTP, UserRole
from app.repositories.user_repository import UserRepository
from app.schemas.user import (
    UserRegisterRequest,
    UserLoginRequest,
    OAuthLoginRequest,
    ForgotPasswordRequest,
    ResetPasswordOTPRequest,
    UserUpdateRequest,
    ChangePasswordRequest,
    DeleteAccountRequest
)
from app.core.security import (
    get_password_hash,
    verify_password,
    create_access_token,
    generate_numeric_otp,
    generate_biometric_challenge
)

class AuthService:
    def __init__(self, user_repo: UserRepository):
        self.user_repo = user_repo

    async def register(self, req: UserRegisterRequest) -> Tuple[User, str]:
        if not req.email and not req.phone:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Cần cung cấp ít nhất Email hoặc Số điện thoại để đăng ký."
            )

        if req.email:
            existing = await self.user_repo.get_by_email(req.email)
            if existing:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Email này đã được sử dụng."
                )

        if req.phone:
            existing = await self.user_repo.get_by_phone(req.phone)
            if existing:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Số điện thoại này đã được sử dụng."
                )

        new_user = User(
            email=req.email,
            phone=req.phone,
            hashed_password=get_password_hash(req.password),
            full_name=req.full_name,
            location_city=req.location_city or "TP. Hồ Chí Minh",
            role=UserRole.USER,
            is_active=True
        )
        user = await self.user_repo.create(new_user)
        token = create_access_token(user.id)
        return user, token

    async def login(self, req: UserLoginRequest) -> Tuple[User, str]:
        user = None
        if "@" in req.identifier:
            user = await self.user_repo.get_by_email(req.identifier)
        else:
            user = await self.user_repo.get_by_phone(req.identifier)

        if not user or not user.hashed_password:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Thông tin đăng nhập không chính xác."
            )

        if not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Tài khoản đã bị tạm khóa do vi phạm tiêu chuẩn cộng đồng."
            )

        if not verify_password(req.password, user.hashed_password):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Thông tin đăng nhập không chính xác."
            )

        token = create_access_token(user.id)
        return user, token

    async def oauth_login(self, req: OAuthLoginRequest) -> Tuple[User, str]:
        """Xử lý đăng nhập nhanh bằng Google hoặc Apple ID (US-008)"""
        if not req.email:
            req.email = f"user_{req.provider}_{req.id_token[:8]}@urbanplants.vn"

        user = await self.user_repo.get_by_email(req.email)
        if not user:
            user = User(
                email=req.email,
                full_name=req.full_name or f"Người dùng {req.provider.capitalize()}",
                avatar_url=req.avatar_url,
                role=UserRole.USER,
                is_active=True
            )
            user = await self.user_repo.create(user)

        if not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Tài khoản đã bị tạm khóa."
            )

        token = create_access_token(user.id)
        return user, token

    async def request_password_reset_otp(self, req: ForgotPasswordRequest) -> str:
        """Sinh mã OTP gửi email cho người dùng (US-009)"""
        user = await self.user_repo.get_by_email(req.email)
        if not user:
            # Bảo mật: không báo lỗi người dùng không tồn tại
            return "Nếu email tồn tại trong hệ thống, mã OTP đã được gửi."

        otp_code = generate_numeric_otp(6)
        otp = PasswordResetOTP(
            user_id=user.id,
            otp_code=otp_code,
            expires_at=datetime.utcnow() + timedelta(minutes=15)
        )
        await self.user_repo.create_otp(otp)
        # Trong thực tế gọi SMTP/SendGrid/SES gửi mail
        return f"Mã OTP đã gửi thành công tới {req.email} (Demo OTP: {otp_code})"

    async def reset_password_with_otp(self, req: ResetPasswordOTPRequest) -> bool:
        """Xác thực mã OTP và đặt lại mật khẩu mới (US-009)"""
        user = await self.user_repo.get_by_email(req.email)
        if not user:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Yêu cầu không hợp lệ.")

        otp = await self.user_repo.get_valid_otp(user.id, req.otp_code)
        if not otp:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Mã OTP không đúng hoặc đã sử dụng.")

        if datetime.utcnow() > otp.expires_at:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Mã OTP đã hết hiệu lực (quá 15 phút).")

        otp.is_used = True
        user.hashed_password = get_password_hash(req.new_password)
        user.last_password_changed_at = datetime.utcnow()
        await self.user_repo.update(user)
        return True

    async def update_profile(self, user: User, req: UserUpdateRequest) -> User:
        """Cập nhật thông tin cá nhân và vị trí nhận dự báo thời tiết (US-010)"""
        if req.full_name is not None:
            user.full_name = req.full_name
        if req.avatar_url is not None:
            user.avatar_url = req.avatar_url
        if req.location_city is not None:
            user.location_city = req.location_city
        if req.fcm_token is not None:
            user.fcm_token = req.fcm_token

        return await self.user_repo.update(user)

    async def enable_biometric(self, user: User, public_key: str) -> bool:
        """Kích hoạt xác thực sinh trắc học vân tay / FaceID (US-011)"""
        user.is_biometric_enabled = True
        user.biometric_public_key = public_key
        await self.user_repo.update(user)
        return True

    async def change_password(self, user: User, req: ChangePasswordRequest) -> bool:
        """Đổi mật khẩu định kỳ tăng cường bảo mật (US-012)"""
        if not user.hashed_password or not verify_password(req.old_password, user.hashed_password):
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Mật khẩu hiện tại không đúng.")

        user.hashed_password = get_password_hash(req.new_password)
        user.last_password_changed_at = datetime.utcnow()
        await self.user_repo.update(user)
        return True

    async def delete_account_permanently(self, user: User, req: DeleteAccountRequest) -> bool:
        """Xóa vĩnh viễn tài khoản & dữ liệu theo tiêu chuẩn CH Play (US-013)"""
        if req.confirm_text.strip().upper() != "XOA TAI KHOAN":
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Vui lòng nhập chính xác cụm từ 'XOA TAI KHOAN' để xác nhận xóa vĩnh viễn."
            )

        if user.hashed_password and req.password:
            if not verify_password(req.password, user.hashed_password):
                raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Mật khẩu xác nhận không đúng.")

        await self.user_repo.delete(user)
        return True
