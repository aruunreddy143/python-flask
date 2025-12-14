from fastapi import FastAPI
from fastapi.responses import JSONResponse
import httpx

app = FastAPI()

# API endpoint that returns todos from JSONPlaceholder API
@app.get("/")
async def hello():
    return {"message": "Hello World from Python ECS! with V3"}

@app.get("/todos")
async def get_todos():
    """Fetch todos from JSONPlaceholder API"""
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get("https://jsonplaceholder.typicode.com/todos")
            response.raise_for_status()
            todos = response.json()
            return {"status": "success", "data": todos}
    except httpx.HTTPError as e:
        return JSONResponse(
            status_code=500,
            content={"status": "error", "message": str(e)}
        )

@app.get("/todos/{todo_id}")
async def get_todo(todo_id: int):
    """Fetch a specific todo by ID"""
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(
                f"https://jsonplaceholder.typicode.com/todos/{todo_id}"
            )
            response.raise_for_status()
            todo = response.json()
            return {"status": "success", "data": todo}
    except httpx.HTTPError as e:
        return JSONResponse(
            status_code=500,
            content={"status": "error", "message": str(e)}
        )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=5000)