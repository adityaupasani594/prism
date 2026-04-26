import sys
import os

# Force local port for the seed script
os.environ["DB_PORT"] = "5433"
os.environ["DB_HOST"] = "localhost"

# Add the apps/api directory to sys.path to import local modules
sys.path.append(os.path.join(os.path.dirname(__file__), '../apps/api'))

from database import SessionLocal, engine
import models

def seed():
    # Ensure tables exist
    models.Base.metadata.create_all(bind=engine)
    
    db = SessionLocal()
    try:
        # Check if already seeded
        if db.query(models.DataRequest).first():
            print("Marketplace already has data. Skipping seed.")
            return

        sample_requests = [
            {
                "requester_name": "Tesla India",
                "title": "EV Consumer Interest in Pune",
                "description": "We are seeking data on electric vehicle charging habits and purchase intent among homeowners in Pune.",
                "reward_amount": "₹750",
                "privacy_policy_raw": """
                    Tesla Privacy Policy: We collect location data and home charging capacity. 
                    Data is anonymized and used exclusively for infrastructure planning. 
                    No third-party sharing. 
                    Data deleted after 12 months.
                """
            },
            {
                "requester_name": "Apollo Hospitals",
                "title": "Health Lifestyle Survey",
                "description": "Seeking voluntary disclosure of exercise routines and step counts for public health research.",
                "reward_amount": "₹300",
                "privacy_policy_raw": """
                    Apollo Health Privacy: We collect step count and average heart rate.
                    Data is used for clinical research only. 
                    Personal Identifiable Information (PII) is removed. 
                    Participants can withdraw at any time.
                """
            },
            {
                "requester_name": "Zomato",
                "title": "Dietary Trends Analysis",
                "description": "Help us understand food ordering preferences for calorie-conscious users.",
                "reward_amount": "₹150",
                "privacy_policy_raw": """
                    Zomato Data Policy: We track order frequency for specific food categories.
                    Insights are used to optimize delivery routes and menu recommendations.
                    Standard encryption protocols applied.
                """
            }
        ]

        for req in sample_requests:
            new_req = models.DataRequest(**req)
            db.add(new_req)
        
        db.commit()
        print("Marketplace successfully seeded with 3 sample requests.")
    except Exception as e:
        print(f"Error seeding data: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    seed()
