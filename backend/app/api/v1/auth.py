from fastapi import APIRouter, Depends, status
from app.api.deps import get_auth_service, get_current_active_user
from app.services.auth_service import AuthService
from app.models.user import User
from app.schemas.user import (
    UserRegisterRequest,
    UserLoginRequest,
    OAuthLoginRequest,
    ForgotPasswordRequest,
    ResetPasswordOTPRequest,
    BiometricEnableRequest,
    ChangePasswordRequest,
    TokenResponse,
    UserResponse
)

router = APIRouter(prefix="/auth", tags=["Authentication & Security"])

@router.post("/register", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
async def register(
    req: UserRegisterRequest,
    auth_service: AuthService = Depends(get_auth_service)
):
    """US-007: Đăng ký tài khoản mới bằng Email hoặc Số điện thoại"""
    user, token = await auth_service.register(req)
    return TokenResponse(access_token=token, user=UserResponse.model_validate(user))

@router.post("/login", response_model=TokenResponse)
async def login(
    req: UserLoginRequest,
    auth_service: AuthService = Depends(get_auth_service)
):
    """Đăng nhập bằng Email/SĐT và mật khẩu"""
    user, token = await auth_service.login(req)
    return TokenResponse(access_token=token, user=UserResponse.model_validate(user))

@router.post("/oauth", response_model=TokenResponse)
async def oauth_login(
    req: OAuthLoginRequest,
    auth_service: AuthService = Depends(get_auth_service)
):
    """US-008: Đăng nhập nhanh bằng Google hoặc Apple ID"""
    user, token = await auth_service.oauth_login(req)
    return TokenResponse(access_token=token, user=UserResponse.model_validate(user))

@router.post("/forgot-password")
async def forgot_password(
    req: ForgotPasswordRequest,
    auth_service: AuthService = Depends(get_auth_service)
):
    """US-009: Yêu cầu gửi mã OTP 6 số về Email để đặt lại mật khẩu"""
    message = await auth_service.request_password_reset_otp(req)
    return {"status": "success", "message": message}

@router.post("/reset-password")
async def reset_password_otp(
    req: ResetPasswordOTPRequest,
    auth_service: AuthService = Depends(get_auth_service)
):
    """US-009: Xác thực OTP và đặt mật khẩu mới"""
    await auth_service.reset_password_with_otp(req)
    return {"status": "success", "message": "Đặt lại mật khẩu thành công. Vui lòng đăng nhập lại."}

@router.post("/biometric/enable")
async def enable_biometric(
    req: BiometricEnableRequest,
    current_user: User = Depends(get_current_active_user),
    auth_service: AuthService = Depends(get_auth_service)
):
    """US-011: Kích hoạt xác thực sinh trắc học (vân tay / FaceID)"""
    await auth_service.enable_biometric(current_user, req.biometric_public_key)
    return {"status": "success", "message": "Đã kích hoạt xác thực sinh trắc học thành công."}

@router.post("/change-password")
async def change_password(
    req: ChangePasswordRequest,
    current_user: User = Depends(get_current_active_user),
    auth_service: AuthService = Depends(get_auth_service)
):
    """US-012: Đổi mật khẩu định kỳ tăng cường bảo mật"""
    await auth_service.change_password(current_user, req)
    return {"status": "success", "message": "Đổi mật khẩu thành công."}
