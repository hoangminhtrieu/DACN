from typing import List, Optional
from fastapi import HTTPException, status
from app.models.user import User, UserRole
from app.repositories.user_repository import UserRepository
from app.schemas.user import RoleUpdateRequest, UserStatusUpdateRequest

class AdminService:
    def __init__(self, user_repo: UserRepository):
        self.user_repo = user_repo

    async def get_all_users(self, skip: int = 0, limit: int = 50) -> List[User]:
        return await self.user_repo.list_users(skip=skip, limit=limit)

    async def update_user_role(self, admin_user: User, target_user_id: str, req: RoleUpdateRequest) -> User:
        """Phân quyền tài khoản: USER, VIP, EXPERT, ADMIN (US-014)"""
        if admin_user.role != UserRole.ADMIN:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Chỉ Quản trị viên cấp cao mới có quyền thay đổi vai trò người dùng."
            )

        target_user = await self.user_repo.get_by_id(target_user_id)
        if not target_user:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Không tìm thấy người dùng.")

        target_user.role = req.role
        return await self.user_repo.update(target_user)

    async def update_user_status(self, admin_user: User, target_user_id: str, req: UserStatusUpdateRequest) -> User:
        """Khóa hoặc kích hoạt tài khoản khi vi phạm tiêu chuẩn cộng đồng (US-015)"""
        if admin_user.role != UserRole.ADMIN:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Chỉ Quản trị viên cấp cao mới có quyền khóa hoặc mở khóa tài khoản."
            )

        target_user = await self.user_repo.get_by_id(target_user_id)
        if not target_user:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Không tìm thấy người dùng.")

        if target_user.id == admin_user.id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Không thể tự khóa tài khoản Admin của chính mình."
            )

        target_user.is_active = req.is_active
        return await self.user_repo.update(target_user)
