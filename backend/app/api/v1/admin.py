from typing import List
from fastapi import APIRouter, Depends, status
from app.api.deps import require_admin, get_admin_service
from app.models.user import User
from app.services.admin_service import AdminService
from app.schemas.user import UserResponse, RoleUpdateRequest, UserStatusUpdateRequest

router = APIRouter(prefix="/admin", tags=["Admin Management & Governance"])

@router.get("/users", response_model=List[UserResponse])
async def list_users(
    skip: int = 0,
    limit: int = 50,
    admin_user: User = Depends(require_admin),
    admin_service: AdminService = Depends(get_admin_service)
):
    """Lấy danh sách tất cả người dùng trong hệ thống"""
    users = await admin_service.get_all_users(skip=skip, limit=limit)
    return [UserResponse.model_validate(u) for u in users]

@router.put("/users/{user_id}/role", response_model=UserResponse)
async def update_user_role(
    user_id: str,
    req: RoleUpdateRequest,
    admin_user: User = Depends(require_admin),
    admin_service: AdminService = Depends(get_admin_service)
):
    """US-014: Phân quyền người dùng (USER, VIP, EXPERT, ADMIN)"""
    updated_user = await admin_service.update_user_role(admin_user, user_id, req)
    return UserResponse.model_validate(updated_user)

@router.put("/users/{user_id}/status", response_model=UserResponse)
async def update_user_status(
    user_id: str,
    req: UserStatusUpdateRequest,
    admin_user: User = Depends(require_admin),
    admin_service: AdminService = Depends(get_admin_service)
):
    """US-015: Khóa hoặc kích hoạt tài khoản khi vi phạm tiêu chuẩn cộng đồng"""
    updated_user = await admin_service.update_user_status(admin_user, user_id, req)
    return UserResponse.model_validate(updated_user)
