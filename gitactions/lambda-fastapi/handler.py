from mangum import Mangum

from fastapi import FastAPI
from contextlib import asynccontextmanager
from src.models.database_models import beanie_docs_init


@asynccontextmanager
async def lifespan(app: FastAPI):
    print("This is the start event")
    yield


app = FastAPI(lifespan=lifespan)

handler = Mangum(app)