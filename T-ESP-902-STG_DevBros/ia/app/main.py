from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware

from app.api.routes.debug import router as debug_router
from app.api.routes.inspection import router as inspection_router
from app.core.logging import clear_request_id, configure_logging, new_request_id, set_request_id
from app.core.settings import get_settings


def create_app() -> FastAPI:
    settings = get_settings()
    configure_logging(settings.log_level)

    application = FastAPI(title="Vetement Inspector API (Multitask)")
    application.add_middleware(
        CORSMiddleware,
        allow_origins=list(settings.cors_origins),
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    @application.middleware("http")
    async def attach_request_id(request: Request, call_next):
        request_id = request.headers.get("X-Request-ID") or new_request_id()
        set_request_id(request_id)
        request.state.request_id = request_id
        response = None
        try:
            response = await call_next(request)
        finally:
            clear_request_id()
        if response is None:
            raise RuntimeError("Response was not created by downstream middleware.")
        response.headers["X-Request-ID"] = request_id
        return response

    application.include_router(inspection_router)
    application.include_router(debug_router)
    return application


app = create_app()
