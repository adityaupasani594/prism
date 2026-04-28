import os
import sys

# Force local port for the seed script when using the bundled Docker setup.
os.environ["DB_PORT"] = "5433"
os.environ["DB_HOST"] = "localhost"

# Add the apps/api directory to sys.path to import local modules.
sys.path.append(os.path.join(os.path.dirname(__file__), "../apps/api"))

from database import SessionLocal, engine
import models


def seed():
    models.Base.metadata.create_all(bind=engine)

    db = SessionLocal()
    try:
        if db.query(models.DataRequest).first():
            print("Consent Exchange already has data. Skipping seed.")
            return

        sample_requests = [
            {
                "requester_name": "Tesla India",
                "title": "EV Consumer Interest in Pune",
                "description": "We need privacy-preserving regional demand signals for EV charging and purchase intent among homeowners in Pune.",
                "purpose": "EV infrastructure planning",
                "category": "Regional mobility insight",
                "scope": {"fields": ["ev_interest", "charging_access", "locality"]},
                "disclosure_modes": ["regional_anonymized"],
                "credit_offer": "750 partner credits",
                "region": "Pune",
                "minimum_cohort_size": 100,
                "duration_days": 30,
                "reward_amount": "750 credits",
                "privacy_policy_raw": """
                    Tesla Privacy Policy: We collect EV interest, charging access,
                    and locality bands. Data is anonymized and used exclusively
                    for infrastructure planning. No third-party sharing. Data is
                    deleted after 12 months.
                """,
            },
            {
                "requester_name": "Apollo Hospitals",
                "title": "Health Lifestyle Survey",
                "description": "Seeking consented health lifestyle signals for public health research, with anonymized regional output as default.",
                "purpose": "Public health lifestyle research",
                "category": "Health research",
                "scope": {"fields": ["step_count_band", "exercise_frequency", "age_band"]},
                "disclosure_modes": ["regional_anonymized", "limited_raw"],
                "credit_offer": "300 wellness credits",
                "region": "Bengaluru",
                "minimum_cohort_size": 150,
                "duration_days": 45,
                "reward_amount": "300 credits",
                "privacy_policy_raw": """
                    Apollo Health Privacy: We collect step-count bands and
                    exercise frequency. Data is used for clinical research only.
                    Personal identifiers are removed. Participants can withdraw
                    at any time.
                """,
            },
            {
                "requester_name": "Zomato",
                "title": "Dietary Trends Analysis",
                "description": "Help us understand regional food preference trends without exposing individual order histories.",
                "purpose": "Regional dietary trend analysis",
                "category": "Food preference insight",
                "scope": {"fields": ["diet_preference", "order_frequency_band", "city_zone"]},
                "disclosure_modes": ["regional_anonymized", "verified_proof"],
                "credit_offer": "150 meal credits",
                "region": "Hyderabad",
                "minimum_cohort_size": 120,
                "duration_days": 21,
                "reward_amount": "150 credits",
                "privacy_policy_raw": """
                    Zomato Data Policy: We use food-category preference bands and
                    city-zone trends to improve recommendations and logistics.
                    PRISM should only release aggregate regional insight unless
                    the user explicitly selects another disclosure mode.
                """,
            },
        ]

        for request in sample_requests:
            db.add(models.DataRequest(**request))

        db.commit()
        print("Consent Exchange successfully seeded with 3 sample requests.")
    except Exception as exc:
        print(f"Error seeding data: {exc}")
        db.rollback()
    finally:
        db.close()


if __name__ == "__main__":
    seed()
