import os

import uvicorn
from fastapi import FastAPI

app = FastAPI()
port = os.getenv("PORT", "8080")
host = os.getenv("HOST", "0.0.0.0")


@app.get("/")
def read_root():
    return {"Hello": "World"}


if __name__ == "__main__":
    uvicorn.run("main:app", host=host, port=int(port), log_level="info")
