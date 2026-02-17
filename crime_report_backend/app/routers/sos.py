from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import datetime, timedelta, timezone
from .. import schemas, models, database

router = APIRouter(
    prefix="/sos",
    tags=["SOS"],
)

@router.post("/", response_model=schemas.SOSAlert)
def create_sos_alert(alert: schemas.SOSAlertCreate, db: Session = Depends(database.get_db)):
    """
    Trigger an SOS alert with location data.
    """
    new_alert = models.SOSAlert(
        user_email=alert.user_email,
        lat=alert.lat,
        long=alert.long
    )
    db.add(new_alert)
    db.commit()
    db.refresh(new_alert)
    return new_alert

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
