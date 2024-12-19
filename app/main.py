import subprocess
import sys
from http import HTTPStatus

from fastapi import FastAPI, HTTPException, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError

from . import app_handlers, chair_handlers, internal_handlers, owner_handlers
from .sql import engine

# ref https://learn.microsoft.com/ja-jp/azure/azure-monitor/app/opentelemetry-enable?tabs=python#modify-your-application
# Import the `configure_azure_monitor()` function from the
# `azure.monitor.opentelemetry` package.
from azure.monitor.opentelemetry import configure_azure_monitor

# Import the tracing api from the `opentelemetry` package.
from opentelemetry import trace

# Configure OpenTelemetry to use Azure Monitor with the
# APPLICATIONINSIGHTS_CONNECTION_STRING environment variable.
configure_azure_monitor()

app = FastAPI()
app.include_router(app_handlers.router)
app.include_router(chair_handlers.router)
app.include_router(internal_handlers.router)
app.include_router(owner_handlers.router)


class PostInitializeRequest(BaseModel):
    payment_server: str


class PostInitializeResponse(BaseModel):
    language: str


@app.post("/api/initialize")
def post_initialize(req: PostInitializeRequest) -> PostInitializeResponse:
    result = subprocess.run(
        "../sql/init.sh", stdout=subprocess.PIPE, stderr=subprocess.STDOUT
    )
    if result.returncode != 0:
        raise HTTPException(
            status_code=HTTPStatus.INTERNAL_SERVER_ERROR,
            detail=f"failed to initialize: {result.stdout.decode()}",
        )

    with engine.begin() as conn:
        conn.execute(
            text(
                "UPDATE settings SET value = :value WHERE name = 'payment_gateway_url'",
            ),
            {"value": req.payment_server},
        )

    return PostInitializeResponse(language="python")


@app.exception_handler(SQLAlchemyError)
def sql_alchemy_error_handler(_: Request, exc: SQLAlchemyError) -> JSONResponse:
    message = str(exc)
    print(message, file=sys.stderr)
    return JSONResponse(
        status_code=HTTPStatus.INTERNAL_SERVER_ERROR, content={"message": message}
    )


@app.exception_handler(RequestValidationError)
def validation_exception_handler(
    _: Request, exc: RequestValidationError
) -> JSONResponse:
    message = str(exc.errors())
    print(message, file=sys.stderr)
    return JSONResponse(
        status_code=HTTPStatus.BAD_REQUEST,
        content={"message": message},
    )


@app.exception_handler(HTTPException)
def custom_http_exception_handler(_: Request, exc: HTTPException) -> JSONResponse:
    message = exc.detail
    print(message, file=sys.stderr)
    return JSONResponse(status_code=exc.status_code, content={"message": message})
