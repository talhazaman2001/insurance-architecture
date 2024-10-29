from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from datetime import datetime, timezone, timedelta
import logging
import time
from prometheus_client import Counter, Histogram
from typing import List, Optional
import numpy as np

# Metrics
CLAIMS_PROCESSED = Counter('claims_processed_total', 'Total claims processed')
PROCESSING_TIME = Histogram('claim_processing_seconds', 'Time spent processing claims')
CLAIM_AMOUNTS = Histogram('claim_amounts', 'Distribution of claim amounts')

app = FastAPI(title = "Claims Processing Service",
             description = "Automated claims processing and evaluation",
             version = "1.0.0")

class Claim(BaseModel):
    claim_id: str = Field(..., description = "Unique identifier for the claim")
    policy_id: str = Field(..., description = "Associated policy ID")
    claim_amount: float = Field(..., description = "Amount claimed")
    incident_date: datetime = Field(..., description = "Date of incident")
    claim_type: str = Field(..., description = "Type of claim")
    description: str = Field(..., description = "Claim description")
    supporting_documents: List[str] = Field(..., description = "List of supporting document IDs")
    claimant_info: dict = Field(..., description = "Claimant information")

@app.post("/api/v1/process", response_model = dict, tags = ["Claims Processing"])
async def process_claim(claim:Claim):
    """
    Process and evaluate insurance claims with automated decision making
    """
    start_time = time.time()
    CLAIMS_PROCESSED.inc()
    CLAIM_AMOUNTS.observe(claim.claim_amount)

    try:
        # Validation checks
        validation_results = validate_claim(claim)
        if not validation_results["valid"]:
            return {
                "status": "rejected",
                "reasons": validation_results["reasons"]
            }

        # Process claim
        assessment_result = assess_claim(claim)
        processing_time = time.time() - start_time
        PROCESSING_TIME.observe(processing_time)

        return {
            "claim_id": claim.claim_id,
            "status": assessment_result["status"],
            "approved_amount": assessment_result["approved_amount"],
            "processing_notes": assessment_result["notes"],
            "processing_time": processing_time,
            "next_steps": assessment_result["next_steps"]
        }

    except Exception as e:
        logging.error(f"Error processing claim: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

def validate_claim(claim: Claim) -> dict:
    """Validate claim data and supporting documents"""
    reasons = []
    
    # Check if policy is active
    if not is_policy_active(claim.policy_id):
        reasons.append("Policy not active")

    # Validate incident date
    if claim.incident_date > datetime.now():
        reasons.append("Invalid incident date")

    # Check supporting documents
    if len(claim.supporting_documents) < get_required_documents(claim.claim_type):
        reasons.append("Insufficient supporting documents")

    return {
        "valid": len(reasons) == 0,
        "reasons": reasons
    }

def assess_claim(claim: Claim) -> dict:
    """Assess claim and make processing decision"""
    try:
        # Policy coverage verification
        policy_coverage = verify_policy_coverage(claim.policy_id, claim.claim_amount)
        if not policy_coverage["covered"]:
            return {
                "status": "rejected",
                "approved_amount": 0,
                "notes": f"Policy coverage insufficient: {policy_coverage['reason']}",
                "next_steps": ["Contact customer service for coverage details"]
            }

        # Amount validation
        amount_validation = validate_claim_amount(claim)
        if not amount_validation["valid"]:
            return {
                "status": "under_review",
                "approved_amount": amount_validation["suggested_amount"],
                "notes": f"Amount requires review: {amount_validation['reason']}",
                "next_steps": ["Submit additional documentation", "Await adjuster review"]
            }

        # Document verification
        doc_verification = verify_documents(claim.supporting_documents, claim.claim_type)
        if not doc_verification["complete"]:
            return {
                "status": "pending",
                "approved_amount": 0,
                "notes": "Missing required documentation",
                "next_steps": doc_verification["missing_documents"]
            }

        # Automated approval rules
        if claim.claim_amount <= 5000 and doc_verification["complete"]:
            return {
                "status": "approved",
                "approved_amount": claim.claim_amount,
                "notes": "Auto-approved based on amount and complete documentation",
                "next_steps": ["Process payment", "Send confirmation to customer"]
            }

        # Regular processing path
        return {
            "status": "in_review",
            "approved_amount": 0,
            "notes": "Claim under standard review process",
            "next_steps": [
                "Adjuster assignment",
                "Documentation review",
                "Customer contact if needed"
            ]
        }

    except Exception as e:
        logging.error(f"Error processing claim {claim.claim_id}: {str(e)}")
        return {
            "status": "error",
            "approved_amount": 0,
            "notes": "System error during processing",
            "next_steps": ["Claim flagged for manual review"]
        }

def verify_policy_coverage(policy_id: str, claim_amount: float) -> dict:
    """Verify if policy covers the claim amount"""
    # In real implementation, would check policy database
    return {
        "covered": True if claim_amount <= 50000 else False,
        "reason": "Amount exceeds policy limit" if claim_amount > 50000 else "Within policy limits"
    }

def validate_claim_amount(claim: Claim) -> dict:
    """Validate claim amount against policy limits and typical ranges"""
    typical_ranges = {
        "auto": {"min": 500, "max": 25000},
        "health": {"min": 100, "max": 50000},
        "property": {"min": 1000, "max": 100000}
    }
    
    range_for_type = typical_ranges.get(claim.claim_type, {"min": 0, "max": float('inf')})
    
    if claim.claim_amount < range_for_type["min"]:
        return {
            "valid": False,
            "suggested_amount": range_for_type["min"],
            "reason": "Amount below typical range"
        }
    elif claim.claim_amount > range_for_type["max"]:
        return {
            "valid": False,
            "suggested_amount": range_for_type["max"],
            "reason": "Amount above typical range"
        }
    
    return {"valid": True, "suggested_amount": claim.claim_amount, "reason": "Amount within normal range"}

def verify_documents(documents: List[str], claim_type: str) -> dict:
    """Verify all required documents are provided"""
    required_docs = get_required_documents(claim_type)
    missing = [doc for doc in required_docs if doc not in documents]
    
    return {
        "complete": len(missing) == 0,
        "missing_documents": missing if missing else []
    }

def is_policy_active(policy_id: str) -> bool:
   """
   Check if insurance policy is active and valid.
   """
   try:
       # In real implementation, this would check policy database
       policy_status = {
           "payment_status": "current",  # current, overdue, cancelled
           "expiry_date": datetime.now(timezone.utc) + timedelta(days=180),
           "policy_restrictions": [],
           "last_payment_date": datetime.now(timezone.utc) - timedelta(days=15)
       }
       
       return all([
           policy_status["payment_status"] == "current",
           policy_status["expiry_date"] > datetime.now(timezone.utc),
           len(policy_status["policy_restrictions"]) == 0,
           (datetime.now(timezone.utc) - policy_status["last_payment_date"]).days < 30
       ])
   except Exception as e:
       logging.error(f"Error checking policy {policy_id}: {str(e)}")
       return False

def get_required_documents(claim_type: str) -> int:
   """
   Return minimum required documents for claim type.
   """
   document_requirements = {
       "health": {
           "required": [
               "medical_report",
               "prescription",
               "receipts",
               "claim_form"
           ],
           "optional": [
               "specialist_report",
               "test_results"
           ]
       },
       "auto": {
           "required": [
               "police_report",
               "repair_estimate",
               "photos",
               "claim_form"
           ],
           "optional": [
               "witness_statements",
               "third_party_details"
           ]
       },
       "property": {
           "required": [
               "damage_photos",
               "value_estimate",
               "ownership_proof",
               "claim_form"
           ],
           "optional": [
               "police_report",
               "repair_quotes"
           ]
       },
       "life": {
           "required": [
               "death_certificate",
               "beneficiary_id",
               "claim_form",
               "medical_records"
           ],
           "optional": [
               "police_report",
               "coroner_report"
           ]
       }
   }
   
   return len(document_requirements.get(claim_type, {}).get("required", []))
