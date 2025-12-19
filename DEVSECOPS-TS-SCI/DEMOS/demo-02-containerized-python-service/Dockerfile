FROM python:3.12-slim

WORKDIR /app

# Keep base image lean; install deps first for layer caching
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

COPY src /app/src

EXPOSE 8080

CMD ["python", "-m", "uvicorn", "demo_service.main:app", "--host", "0.0.0.0", "--port", "8080", "--app-dir", "/app/src"]
