import cloudinary
import cloudinary.uploader
import os
from fastapi import HTTPException, UploadFile

# Ensure CLOUDINARY_URL is loaded
if not os.getenv("CLOUDINARY_URL"):
    print("⚠️  WARNING: CLOUDINARY_URL not found in environment variables!")
else:
    # Basic validation (Masked)
    url = os.getenv("CLOUDINARY_URL")
    try:
        if "@" in url and ":" in url:
            print(f"✅ Cloudinary URL found: {url.split('@')[1]}")
        else:
            print("⚠️  Cloudinary URL format looks suspicious.")
    except:
        pass

def upload_to_cloudinary(file: UploadFile, resource_type: str = "auto") -> str:
    """
    Uploads a file to Cloudinary and returns the secure URL.
    
    Args:
        file: The FastAPI UploadFile object.
        resource_type: "image", "video", or "auto".
    
    Returns:
        str: The secure URL of the uploaded asset.
    """
    try:
        # Cloudinary expects a file-like object or path. 
        # UploadFile.file is a SpooledTemporaryFile which works.
        response = cloudinary.uploader.upload(
            file.file,
            resource_type=resource_type,
            folder="crime_reports" # Optional: organize in a folder
        )
        return response.get("secure_url")
    except Exception as e:
        print(f"❌ Cloudinary Upload Error: {e}")
        raise HTTPException(status_code=500, detail=f"Media upload failed: {str(e)}")
