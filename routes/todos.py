from fastapi import APIRouter
from fastapi.responses import JSONResponse
import httpx
import sys
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from config.logger import logger
from config.database import get_table, dynamodb

router = APIRouter(prefix="/todos", tags=["todos"])

@router.get("")
async def get_todos():
    """Fetch todos from JSONPlaceholder API"""
    logger.info("GET /todos - Fetching todos from JSONPlaceholder")
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get("https://jsonplaceholder.typicode.com/todos")
            response.raise_for_status()
            todos = response.json()
            logger.info(f"Successfully fetched {len(todos)} todos from JSONPlaceholder")
            return {"status": "success", "data": todos}
    except httpx.HTTPError as e:
        logger.error(f"Failed to fetch todos: {str(e)}", exc_info=True)
        return JSONResponse(
            status_code=500,
            content={"status": "error", "message": str(e)}
        )

@router.get("/{todo_id}")
async def get_todo(todo_id: int):
    """Fetch a specific todo by ID"""
    logger.info(f"GET /todos/{todo_id} - Fetching specific todo")
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(
                f"https://jsonplaceholder.typicode.com/todos/{todo_id}"
            )
            response.raise_for_status()
            todo = response.json()
            logger.info(f"Successfully fetched todo {todo_id}")
            return {"status": "success", "data": todo}
    except httpx.HTTPError as e:
        logger.error(f"Failed to fetch todo {todo_id}: {str(e)}", exc_info=True)
        return JSONResponse(
            status_code=500,
            content={"status": "error", "message": str(e)}
        )
