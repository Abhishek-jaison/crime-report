from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import text
from .. import database, models

router = APIRouter(
    prefix="/debug",
    tags=["Debug"]
)

@router.get("/database-info")
def get_database_info():
    """Returns safe information about the current database connection."""
    db_url = database.SQLALCHEMY_DATABASE_URL
    is_postgres = "postgresql" in db_url
    
    # Safe masking
    masked_url = "sqlite"
    if is_postgres:
        try:
            # Mask password: postgresql://user:pass@host... -> postgresql://user:***@host...
            parts = db_url.split("@")
            if len(parts) > 1:
                prefix = parts[0].split(":")
                if len(prefix) > 2: # user:pass
                    masked_prefix = f"{prefix[0]}:{prefix[1]}:***"
                    masked_url = f"{masked_prefix}@{parts[1]}"
                else:
                    masked_url = "postgresql://***:***@..."
            else:
                masked_url = "postgresql://..."
        except:
             masked_url = "postgresql://(masked_error)"
             
    display_engine = database.engine.dialect.name

    return {
        "database_url": masked_url,
        "engine_name": display_engine,
        "is_postgres": is_postgres
    }

@router.get("/users-count")
def get_users_count(db: Session = Depends(database.get_db)):
    """Returns the total number of users in the database."""
    try:
        count = db.query(models.User).count()
        return {"users_count": count}
    except Exception as e:
        return {"error": str(e)}
    except Exception as e:
        return {"error": str(e)}

@router.get("/tables")
def get_tables():
    """Returns a list of all tables in the database."""
    from sqlalchemy import inspect
    try:
        inspector = inspect(database.engine)
        tables = inspector.get_table_names()
        return {"tables": tables}
    except Exception as e:
        return {"error": str(e)}
