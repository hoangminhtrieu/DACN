from typing import Optional
from fastapi import APIRouter, Response
from pydantic import BaseModel
from app.services.admin_cms_service import admin_cms_service

router = APIRouter(prefix="/admin", tags=["Admin Dashboard, Disease Heatmap & CMS"])

class PublishModelRequest(BaseModel):
    version: str
    file_size_mb: float
    checksum_sha256: str
    download_url: str
    changelog: str

@router.get("/dashboard/overview")
def get_dashboard_overview():
    """US-093: Bảng điều khiển tổng quan DAU/MAU, lượt quét AI và doanh thu"""
    return admin_cms_service.get_dashboard_overview()

@router.get("/disease-heatmap")
def get_disease_heatmap(city: Optional[str] = None):
    """US-094: Bản đồ nhiệt phân bố dịch bệnh cây cảnh theo từng quận/khu vực"""
    return admin_cms_service.get_disease_heatmap(city)

@router.get("/ota-model/latest")
def get_latest_ota_model():
    """US-096: Kiểm tra phiên bản mô hình AI TFLite mới nhất để app cập nhật ngầm"""
    return admin_cms_service.get_latest_ota_model()

@router.post("/ota-model/publish")
def publish_new_ota_model(req: PublishModelRequest):
    """US-096: Admin xuất bản phiên bản TFLite mới lên hệ thống OTA"""
    return admin_cms_service.publish_new_ota_model(
        version=req.version,
        file_size_mb=req.file_size_mb,
        checksum=req.checksum_sha256,
        download_url=req.download_url,
        changelog=req.changelog
    )

@router.get("/reports/export-csv")
def export_analytics_csv():
    """US-098: Xuất báo cáo thống kê dịch bệnh và doanh thu ra tệp CSV/Excel"""
    csv_data = admin_cms_service.export_analytics_csv()
    return Response(
        content=csv_data,
        media_type="text/csv",
        headers={"Content-Disposition": "attachment; filename=urban_plants_disease_report.csv"}
    )
