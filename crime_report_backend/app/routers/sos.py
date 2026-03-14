from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import datetime, timedelta, timezone
from pydantic import BaseModel
from .. import schemas, models, database

router = APIRouter(
    prefix="/sos",
    tags=["SOS"],
)

ALLOWED_SOS_STATUSES = {"Pending", "Dispatched", "Resolved", "Dismissed"}

class SOSStatusUpdate(BaseModel):
    status: str

@router.post("/", response_model=schemas.SOSAlert)
def create_sos_alert(alert: schemas.SOSAlertCreate, db: Session = Depends(database.get_db)):
    """
    Trigger an SOS alert with location data. Status defaults to Pending.
    """
    new_alert = models.SOSAlert(
        user_email=alert.user_email,
        lat=alert.lat,
        long=alert.long,
        status="Pending"
    )
    db.add(new_alert)
    db.commit()
    db.refresh(new_alert)
    return new_alert

@router.patch("/{alert_id}/status", response_model=schemas.SOSAlert)
def update_sos_status(
    alert_id: int,
    update: SOSStatusUpdate,
    db: Session = Depends(database.get_db)
):
    """Update the status of an SOS alert (admin action)."""
    if update.status not in ALLOWED_SOS_STATUSES:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid status. Must be one of: {', '.join(ALLOWED_SOS_STATUSES)}"
        )
    alert = db.query(models.SOSAlert).filter(models.SOSAlert.id == alert_id).first()
    if not alert:
        raise HTTPException(status_code=404, detail="SOS alert not found")
    alert.status = update.status
    db.commit()
    db.refresh(alert)
    return alert

@router.get("/stats")
def get_sos_stats(db: Session = Depends(database.get_db)):
    """
    Get total SOS alerts and today's alerts count.
    """
    total_alerts = db.query(models.SOSAlert).count()
    
    # Get today's alerts (Postgres specific date function or python based)
    today = datetime.now(timezone.utc).date()
    # Use 24h window for consistency with complaints
    cutoff = datetime.now(timezone.utc) - timedelta(hours=24)
    
    today_alerts = db.query(models.SOSAlert).filter(
        models.SOSAlert.created_at >= cutoff
    ).count()
    
    return {
        "total_alerts": total_alerts,
        "today_alerts": today_alerts
    }

@router.get("/all", response_model=list[schemas.SOSAlert])
def get_all_sos_alerts(db: Session = Depends(database.get_db)):
    """
    Get all SOS alerts with their coordinates (for the heat map).
    """
    return db.query(models.SOSAlert).order_by(models.SOSAlert.created_at.desc()).all()
