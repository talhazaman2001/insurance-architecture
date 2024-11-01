from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from datetime import datetime, timezone
import logging
from prometheus_client import Counter, Histogram
import time
from typing import List, Optional
import numpy as np

# Metrics
FRAUD_CHECKS = Counter('fraud_checks_total', 'Total Fraud Checks performed')
FRAUD_SCORE = Histogram('fraud_risk_score', 'Distribution of Fraud Risk Scores')
PROCESSING_TIME = Histogram('fraud_check_processing_seconds', 'Time spent processing Fraud Checks')

app = FastAPI(title = 'FraudDetectionEngine',
              description = "Fraud Detection for Insurance Claims",
              version = "1.0.0")

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

class ClaimData(BaseModel):
    claim_id: str = Field(..., description = "Unique identifier for the claim")
    policy_id: str = Field(..., description = "Associated Policy ID")
    claim_amount: float = Field(..., description = "Amount claimed")
    claim_type: str = Field(..., description = "Type of Insurance Claim")
    claimant_age: int = Field(..., description = "Age of Claimant")
    claim_date: datetime = Field(..., description = "Date of Claim Submission")
    previous_claims: int = Field(..., description = "Number of Previous Claims") 
    policy_start_date: datetime = Field(..., description = "Policy Start Date")
    location : str = Field(..., description = "Claim Location")
    device_ip: Optional[str] = Field(None, description = "IP Address of submission device")

@app.post("/api/v1/detect", response_model = dict, tags = ["Fraud Detection"])
async def detect_fraud(claim:ClaimData):
    """
    Detect Potential Fraud in Insurance Claims using multiple risk factors and ML-based scoring.
    """
    start_time = time.time()
    FRAUD_CHECKS.inc()

    try:
        # Fraud Detection Logic
        risk_factors = []
        risk_scores = []

        # Time-based analysis
        days_since_policy_start = (claim.claim_date - claim.policy_start_date).days
        if days_since_policy_start < 30:
            risk_factors.append("Very Recent Policy")
            risk_scores.append(35)

        # Amount analysis with statistical thresholds
        if claim.claim_amount > 50000:
            risk_factors.append("High Claim Amount")
            risk_scores.append(25)

        # Frequency Analysis
        if claim.previous_claims > 3:
            risk_factors.append("Multiple Previous Claims")
            risk_scores.append(30)

        # Location-based risk
        high_risk_locations = ['NK', 'IR', 'CU']
        if claim.location in high_risk_locations:
            risk_factors.append('High Risk Location Detected')
            risk_scores.append(40)

        # Age-based risk assessment
        if claim.claimant_age < 25:
            risk_factors.append("High Risk Age Group")
            risk_scores.append(10)

        # Composite Risk Score Calculation
        base_risk_score = sum(risk_scores)
        weighted_score = base_risk_score * (1 + (claim.previous_claims * 0.1))
        final_score = min(100, weighted_score)

        FRAUD_SCORE.observe(final_score)

        response = {
            "claim_id": claim.claim_id,
            "risk_score": final_score,
            "risk_factors": risk_factors,
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "status": "high_risk" if final_score > 70 else "medium_risk" if final_score > 30 else "low_risk",
            "confidence": "high" if len(risk_factors) > 3 else "medium" if len(risk_factors) > 1 else "low"
        }

        processing_time = time.time() - start_time
        PROCESSING_TIME.observe(processing_time)

        return response
    
    except Exception as e:
        logging.error(f"Error in Fraud Detection: {str(e)}")
        raise HTTPException(status_code = 500, detail = str(e))
    
@app.get("/health")
async def health_check():
    """
    Health Check Endpoint for Load Balancer Checks
    """

    return {"status": "healthy", "service": "fraud-detection"}

@app.get("/metrics")
async def metrics():
    """
    Prometheus Metrics Endpoint
    """
    from prometheus_client import generate_latest
    return generate_latest()

