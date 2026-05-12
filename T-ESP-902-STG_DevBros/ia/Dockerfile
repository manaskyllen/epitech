FROM pytorch/pytorch:2.2.0-cuda11.8-cudnn8-runtime

ARG USER=appuser
ARG UID=1000

RUN groupadd -g ${UID} ${USER} || true && \
    useradd --no-log-init -m -d /home/${USER} -r -u ${UID} -g ${USER} ${USER}

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libglib2.0-0 \
    libgl1 \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt ./

RUN pip install --no-cache-dir -U pip setuptools wheel
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN mkdir -p /app/artifacts/models /app/artifacts/encoders /app/data /app/logs /app/.cache/torch /app/.cache/ultralytics /home/${USER} && \
    chown -R ${USER}:${USER} /app /home/${USER}

ENV HOME=/home/${USER}
ENV XDG_CACHE_HOME=/app/.cache
ENV TORCH_HOME=/app/.cache/torch
ENV YOLO_CONFIG_DIR=/app/.cache/ultralytics
ENV PATH=/opt/conda/bin:${PATH}
ENV PYTHONUNBUFFERED=1

USER ${USER}

CMD ["python", "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
