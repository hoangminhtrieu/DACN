import sys
from pathlib import Path
_project_root = str(Path(__file__).resolve().parents[2])
if _project_root not in sys.path:
    sys.path.insert(0, _project_root)

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from app.core.config import settings
from app.core.database import engine, Base, AsyncSessionLocal
import app.models.user as _user_model
import app.models.garden as _garden_model
import app.models.treatment as _treatment_model
import app.models.commerce as _commerce_model
from app.api.v1 import auth, users, admin, garden, weather, diagnosis, treatment, voice, commerce

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Khởi tạo bảng dữ liệu khi start app (tương thích SQLite & PostgreSQL)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    # Tự động khởi tạo tài khoản quản trị & danh mục cây ban đầu nếu CSDL mới tinh (Railway PostgreSQL)
    try:
        from sqlalchemy import select
        from app.models.user import User, UserRole
        from app.core.security import get_password_hash
        from app.repositories.garden_repository import GardenRepository

        async with AsyncSessionLocal() as session:
            admin_check = await session.execute(select(User).where(User.email == "admin@urbanplants.vn"))
            if not admin_check.scalars().first():
                session.add(User(
                    email="admin@urbanplants.vn",
                    hashed_password=get_password_hash("Admin@123456"),
                    full_name="Hệ Thống Quản Trị Urban Plants",
                    role=UserRole.ADMIN,
                    is_active=True
                ))

            user_check = await session.execute(select(User).where(User.email == "trieu.urbanplants@gmail.com"))
            if not user_check.scalars().first():
                session.add(User(
                    email="trieu.urbanplants@gmail.com",
                    hashed_password=get_password_hash("Trieu@123456"),
                    full_name="Hoàng Minh Triều",
                    role=UserRole.USER,
                    is_active=True
                ))

            await session.commit()
            repo = GardenRepository(session)
            await repo.seed_default_catalog_if_empty()
    except Exception as e:
        print(f"[Lifespan] Khởi tạo dữ liệu ban đầu: {e}")

    yield

app = FastAPI(
    title=settings.APP_NAME,
    description="Hệ thống Backend API cho Dự án Urban Plants - Nền tảng Chăm sóc Cây cảnh Đô thị & Chẩn đoán Bệnh AI",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan
)

# Cấu hình CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.BACKEND_CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    )

# Đăng ký các router v1
app.include_router(auth.router, prefix=settings.API_V1_PREFIX)
app.include_router(users.router, prefix=settings.API_V1_PREFIX)
app.include_router(admin.router, prefix=settings.API_V1_PREFIX)
app.include_router(garden.router, prefix=settings.API_V1_PREFIX)
app.include_router(weather.router, prefix=settings.API_V1_PREFIX)
app.include_router(diagnosis.router, prefix=settings.API_V1_PREFIX)
app.include_router(treatment.router, prefix=settings.API_V1_PREFIX)
app.include_router(voice.router, prefix=settings.API_V1_PREFIX)
app.include_router(commerce.router, prefix=settings.API_V1_PREFIX)

@app.get("/health", tags=["Health Check"])
async def health_check():
    return {
        "status": "healthy",
        "app": settings.APP_NAME,
        "environment": settings.APP_ENV
    }
