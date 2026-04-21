import os
import google.generativeai as genai
from dotenv import load_dotenv

load_dotenv()

# Configure Gemini
api_key = os.getenv("GOOGLE_API_KEY")
if api_key:
    genai.configure(api_key=api_key)

class GeminiService:
    def __init__(self):
        self.model = genai.GenerativeModel('gemini-1.5-flash')

    async def summarize_policy(self, policy_text: str):
        """
        Summarizes a privacy policy into 3 bullets in Hindi and English.
        """
        prompt = f"""
        Act as a specialized legal plain-language expert for the DPDP Act. 
        Analyze the following privacy policy and provide a summary in exactly 3 bullet points.
        Each bullet point must be present in both English and Hindi.
        
        Format:
        - [English Point] / [Hindi Point]
        
        Privacy Policy Text:
        {policy_text}
        """
        
        try:
            if not api_key:
                return "AI Summary unavailable (API Key not configured). / एआई सारांश उपलब्ध नहीं है (एपीआई कुंजी कॉन्फ़िगर नहीं की गई है)।"
            
            response = self.model.generate_content(prompt)
            return response.text
        except Exception as e:
            print(f"Gemini API Error: {e}")
            return "Failed to generate summary. / सारांश उत्पन्न करने में विफल।"

    async def analyze_compliance(self, content_to_scan: str):
        """
        Analyzes code or policy text for potential DPDP 2023 violations.
        """
        prompt = f"""
        Act as a DPDP 2023 Compliance Auditor (Static Analysis Mode). 
        Scan the following text/code for potential violations of the Digital Personal Data Protection Act (DPDP).
        
        Specifically check for:
        1. Purpose Limitation (Is the purpose clearly defined?)
        2. Data Minimization (Are only necessary fields requested?)
        3. Notice Requirement (Is a clear notice provided in simple language?)
        4. Right to Withdraw (Is there a clear mention of revocation rights?)
        
        Provide a detailed report in JSON format with:
        - "violations": List of identified gaps.
        - "health_score": A score from 0-100.
        - "recommendations": Actions to fix the gaps.
        
        Content to Scan:
        {content_to_scan}
        
        Output only valid JSON.
        """
        
        try:
            if not api_key:
                return "{\"error\": \"API Key missing\"}"
            
            response = self.model.generate_content(prompt)
            # Remove markdown code blocks if Gemini includes them
            clean_json = response.text.replace('```json', '').replace('```', '').strip()
            return clean_json
        except Exception as e:
            print(f"Gemini Scan Error: {e}")
            return "{\"error\": \"Scan failed\"}"

    async def extract_id_data(self, image_bytes: bytes, mime_type: str):
        """
        Extracts Aadhaar/ID data from an image using Gemini Vision.
        """
        prompt = """
        Act as an Aadhaar/Identity Document OCR specialist. 
        Extract the following data from the provided image:
        1. Full Name (name)
        2. Date of Birth (dob) in DD/MM/YYYY format
        3. Resident Status (status) - usually "VERIFIED INDIAN" or "RESIDENT"
        4. Masked Document ID (docId) - Example: XXXX-XXXX-4282 (Last 4 digits visible)
        
        Rules:
        - If you cannot find a piece of data, return "NOT FOUND".
        - Output only a valid JSON object.
        - Do not include markdown code blocks.
        """
        
        try:
            if not api_key:
                return "{\"error\": \"API Key missing\"}"
            
            contents = [
                prompt,
                {
                    "mime_type": mime_type,
                    "data": image_bytes
                }
            ]
            
            response = self.model.generate_content(contents)
            clean_json = response.text.replace('```json', '').replace('```', '').strip()
            return clean_json
        except Exception as e:
            print(f"Gemini Vision Error: {e}")
            return "{\"error\": \"Extraction failed\"}"

# Singleton instance
gemini_service = GeminiService()
