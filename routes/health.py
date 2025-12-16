from fastapi import APIRouter
from fastapi.responses import JSONResponse
import sys
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from config.logger import logger
from config.database import get_table, dynamodb

router = APIRouter(tags=["health"])

@router.get("/health")
async def check_dynamo():
    """Health check - scans DynamoDB users table"""
    logger.info("GET /health - Health check initiated")
    try:
        table = get_table(dynamodb, "users")
        response = table.scan()
        todos = response.get('Items', [])
        logger.info(f"Successfully scanned users table. Found {len(todos)} items")
        return {"status": "healthy", "todos": todos}
    except Exception as e:
        logger.error(f"Health check failed: {str(e)}", exc_info=True)
        return JSONResponse(
            status_code=500,
            content={"status": "error", "message": str(e)}
        )

@router.get("/addTodo")
async def add_todo():
    """Add a sample todo to DynamoDB table"""
    logger.info("GET /addTodo - Adding todo")
    try:
        table = get_table(dynamodb, "users")
        todo_item = {
            'email': '1',
            'followers': 300,
            'completed': False
        }
        table.put_item(Item=todo_item)
        logger.info(f"Successfully added todo item: {todo_item}")
        return {"status": "success", "message": "Todo added successfully"}
    except Exception as e:
        logger.error(f"Failed to add todo: {str(e)}", exc_info=True)
        return JSONResponse(
            status_code=500,
            content={"status": "error", "message": str(e)}
        )
