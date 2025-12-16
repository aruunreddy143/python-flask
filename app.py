from fastapi import FastAPI
from config.logger import logger
from routes.todos import router as todos_router
from routes.health import router as health_router

app = FastAPI(title="Todo API", version="1.0.0")

# Include routers
app.include_router(todos_router)
app.include_router(health_router)

@app.get("/")
async def hello():
    logger.info("GET / - Hello endpoint called")
    return {"message": "Hello World from Python ECS! with V6 - Dev Deployment"}

if __name__ == "__main__":
    import uvicorn
    logger.info("Starting FastAPI application on 0.0.0.0:5000")
    uvicorn.run(app, host="0.0.0.0", port=5000)