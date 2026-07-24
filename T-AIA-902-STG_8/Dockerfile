FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1
ENV PYTHONIOENCODING=utf-8
ENV PIP_ROOT_USER_ACTION=ignore

WORKDIR /app

# Upgrade pip silently
RUN pip install --upgrade pip --quiet

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . .

CMD ["python", "app/main.py"]