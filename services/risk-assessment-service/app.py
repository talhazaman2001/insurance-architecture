from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from datetime import datetime, timezone
import logging
from prometheus_client import Counter, Histogram
import time
from typing import List, Optional
import numpy as np

# Metrics
RISK_ASSESSMENTS = Counter('risk_assessment_total', 'Total Risk Assessments performed')
RISK_SCORE = Histogram('risk_assessment_score', 'Distribution of Risk Assessment Scores')
PROCESSING_TIME = Histogram('risk_assessment_processing_seconds', 'Time spent processing Risk Assessment')

app = FastAPI(title = "Risk Assessment Service",
              description = "Risk Assessment for Insurance Policies",
              version = "1.0.0")

class PolicyData(BaseModel):
    policy_id: str = Field(..., description = "Unique identifier for the policy")
    customer_id: str = Field(..., description = "Customer identifier")
    policy_type: str = Field(..., description = "Type of insurance policy")
    coverage_amount: float = Field(..., description = "Total coverage amount")
    customer_age: int = Field(..., description = "Age of customer")
    occupation: str = Field(..., description = "Customer occupation")
    medical_history: Optional[List[str]] = Field(None, description = "Relevant medical history")
    credit_score: Optional[int] = Field(None, description = "Customer credit score") 

@app.post("/app/v1/assess", response_model = dict, tags = ["Risk Asssessment"])
async def assess_risk(policy:PolicyData):
    """
    Perform Comprehensive Risk Assessment for Insurance Policies
    """

    start_time = time.time()
    RISK_ASSESSMENTS.inc()

    try:
        risk_factors = []
        risk_scores = []

        # Age-based
        age_risk = calculate_age_risk(policy.customer_age, policy.policy_type)
        risk_scores.append(age_risk)

        # Coverage Amount Analysis
        if policy.coverage_amount > 1000000:
            risk_factors.append("High Coverage Amount")
            risk_scores.append(30)

        # Occupation 
        occupation_risk = assess_occupation_risk(policy.occupation)
        risk_scores.append(occupation_risk)

        # Credit Score if available
        if policy.credit_score:
            credit_risk = assess_credit_risk(policy.credit_score)
            risk_scores.append(credit_risk)

        # Calculate final risk score
        final_score = calculated_weighted_risk(risk_scores)
        RISK_SCORE.observe(final_score)

        response = {
            "policy_id": policy.policy_id,
            "risk_score": final_score,
            "risk_factors": risk_factors,
            "assessment_date": datetime.now(timezone.utc).isoformat(),
            "risk_level": determine_risk_level(final_score),
        }

        processing_time = time.time() - start_time
        PROCESSING_TIME.observe(processing_time)

        return response

    except Exception as e:
        logging.error(f"Error in risk assessment: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

def calculate_age_risk(age: int, policy_type: str) -> float:
    # Age risk calculation logic
    base_risk = 0
    if policy_type == "life":
        if age > 60:
            base_risk = 40
        elif age > 40:
            base_risk = 20
    elif policy_type == "health":
        if age > 50:
            base_risk = 35
        elif age > 30:
            base_risk = 15
    return base_risk

def assess_occupation_risk(occupation: str) -> float:
    risk_scores = {
        # High Risk Occupations
        "construction_worker": 80,
        "professional_athlete": 75,
        "miner": 85,
        "firefighter": 70,
        "police_officer": 70,
        "cab_driver": 70,
        "pilot": 65,

        # Medium Risk Occupations
        "nurse": 40,
        "factory_worker": 35,
        "chef": 30,
        
        # Low Risk Occupations
        "teacher": 10,
        "accountant": 10,
        "software_engineer": 10,
        "receptionist": 10
    }

    # Industry-specific modifiers
    industry_multipliers = {
        "oil_and_gas": 1.3,
        "mining": 1.4,
        "healthcare": 1.1,
        "technology": 0.8,
        "education": 0.9
    }

    base_score = risk_scores.get(occupation.lower(), 30) # Default Score if occupation unknown
    return base_score

def assess_credit_risk(credit_score: int) -> float:
    # Credit score bands and associated risk scores
    if credit_score >= 800:
        base_risk = 10  # Excellent
    elif credit_score >= 740:
        base_risk = 20  # Very Good
    elif credit_score >= 670:
        base_risk = 40  # Good
    elif credit_score >= 580:
        base_risk = 70  # Fair
    else:
        base_risk = 90  # Poor
        
    # Additional risk factors
    risk_modifiers = {
        "recent_bankruptcy": 50,
        "multiple_credit_inquiries": 20,
        "high_credit_utilization": 30,
        "missed_payments": 40,
        "account_age": -10  # Negative modifier for long-standing accounts
    }
    
    return base_risk

def calculated_weighted_risk(risk_scores: list[float], weights: dict = None) -> float:
   """
   Calculate weighted risk score considering different risk factors and their importance.
   """
   if weights is None:
       weights = {
           "credit_risk": 0.30,
           "occupation_risk": 0.25,
           "medical_risk": 0.20,
           "location_risk": 0.15,
           "age_risk": 0.10
       }
   
   # Normalise weights if they don't sum to 1
   weight_sum = sum(weights.values())
   normalized_weights = {k: v/weight_sum for k, v in weights.items()}
   
   # Calculate weighted sum
   weighted_sum = sum(score * weight for score, weight in zip(risk_scores, normalized_weights.values()))
   
   return min(100, weighted_sum)  # Cap at 100

def determine_risk_level(risk_score: float) -> dict:
   """
   Determine risk level and provide detailed assessment.
   """
   if risk_score >= 80:
       level = "CRITICAL"
       action = "Immediate review required. Consider denial or specialist assessment."
       premium_modifier = 2.5
   elif risk_score >= 65:
       level = "HIGH"
       action = "Detailed review needed. Consider premium loading."
       premium_modifier = 1.75
   elif risk_score >= 45:
       level = "MEDIUM"
       action = "Standard review process. May require additional documentation."
       premium_modifier = 1.25
   elif risk_score >= 25:
       level = "LOW"
       action = "Standard process. Regular monitoring."
       premium_modifier = 1.0
   else:
       level = "MINIMAL"
       action = "Fast-track approval possible."
       premium_modifier = 0.9
   
   return {
       "risk_level": level,
       "recommended_action": action,
       "premium_modifier": premium_modifier,
       "numerical_score": risk_score,
       "assessment_confidence": "HIGH" if risk_score > 90 or risk_score < 10 else "MEDIUM"
   }

