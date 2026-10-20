from fastapi import APIRouter, Depends, status
from app.api.deps import get_current_active_user, get_auth_service
from app.models.user import User
from app.services.auth_service import AuthService
from app.schemas.user import UserResponse, UserUpdateRequest, DeleteAccountRequest

router = APIRouter(prefix="/users", tags=["Users Profile & Privacy"])

@router.get("/me", response_model=UserResponse)
async def get_my_profile(current_user: User = Depends(get_current_active_user)):
    """Lấy thông tin hồ sơ của người dùng hiện tại"""
    return UserResponse.model_validate(current_user)

@router.put("/me", response_model=UserResponse)
async def update_my_profile(
    req: UserUpdateRequest,
    current_user: User = Depends(get_current_active_user),
    auth_service: AuthService = Depends(get_auth_service)
):
    """US-010: Cập nhật thông tin cá nhân (ảnh đại diện, tên, vị trí sinh sống)"""
    updated_user = await auth_service.update_profile(current_user, req)
    return UserResponse.model_validate(updated_user)

@router.delete("/me", status_code=status.HTTP_200_OK)
async def delete_my_account(
    req: DeleteAccountRequest,
    current_user: User = Depends(get_current_active_user),
    auth_service: AuthService = Depends(get_auth_service)
):
    """US-013: Xóa vĩnh viễn tài khoản và toàn bộ dữ liệu cá nhân theo tiêu chuẩn CH Play"""
    await auth_service.delete_account_permanently(current_user, req)
    return {
        "status": "success",
        "message": "Tài khoản và toàn bộ dữ liệu khu vườn của bạn đã được xóa vĩnh viễn khỏi hệ thống."
    }
