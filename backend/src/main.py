"""
SASI - Energy Fraud Inspection Map System
FastAPI Backend Server
"""
import os
import logging
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from dotenv import load_dotenv

from routes import queries, installations, areas

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

load_dotenv()

app = FastAPI(
    title="SASI - Sistema de Apoio à Seleção de Inspeções",
    description="API para mapa de inspeções de fraude de energia",
    version="1.0.0"
)

# CORS Configuration
origins = os.getenv("CORS_ORIGINS", "http://localhost:5173").split(",")

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global exception handler
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    logger.error(f"Global exception: {exc}", exc_info=True)
    return JSONResponse(
        status_code=500,
        content={"detail": str(exc)}
    )

# Mount routers
app.include_router(queries.router, prefix="/api/queries", tags=["Queries"])
app.include_router(installations.router, prefix="/api/installations", tags=["Installations"])
app.include_router(areas.router, prefix="/api/areas", tags=["Areas"])


@app.get("/")
async def root():
    return {
        "message": "SASI API - Energy Fraud Inspection Map System",
        "version": "1.0.0",
        "docs": "/docs"
    }


@app.get("/health")
async def health():
    return {"status": "healthy"}


if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("API_PORT", 8000))
    uvicorn.run("main:app", host="0.0.0.0", port=port, reload=True)
