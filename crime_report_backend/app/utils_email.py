import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import os
from dotenv import load_dotenv

load_dotenv()

# Configuration (Use Environment Variables in production!)
SMTP_SERVER = "smtp.gmail.com"
SMTP_PORT = 465
SENDER_EMAIL = os.getenv("SENDER_EMAIL")
SENDER_PASSWORD = os.getenv("SENDER_PASSWORD")

def send_otp_email(receiver_email: str, otp: str):
    print(f"------------ OTP LOG ------------")
    print(f"Sending OTP to {receiver_email}: {otp}")
    print(f"---------------------------------")

    if not SENDER_EMAIL or not SENDER_PASSWORD or SENDER_EMAIL == "your-email@gmail.com":
        print("Skipping actual email send: Credentials not configured.")
        return True

    try:
        msg = MIMEMultipart()
        msg['From'] = SENDER_EMAIL
        msg['To'] = receiver_email
        msg['Subject'] = "Your Verification Code - Crime Reporting App"

        body = f"""
        <html>
            <body>
                <h2>Verification Code</h2>
                <p>Your OTP is: <strong>{otp}</strong></p>
                <p>This code is valid for 5 minutes.</p>
            </body>
        </html>
        """
        msg.attach(MIMEText(body, 'html'))

        # Use SMTP_SSL for port 465
        server = smtplib.SMTP_SSL(SMTP_SERVER, SMTP_PORT)
        # server.starttls() # Not needed for SSL
        server.login(SENDER_EMAIL, SENDER_PASSWORD)
        text = msg.as_string()
        server.sendmail(SENDER_EMAIL, receiver_email, text)
        server.quit()
        print("Email sent successfully!")
        return True
    except Exception as e:
        print(f"Failed to send email: {e}")
        return False
