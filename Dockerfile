FROM python:3.11-slim

WORKDIR /app

# Install system dependencies needed for build and headless CV/ML operations
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libgl1 \
    libglib2.0-0 \
    libgomp1 \
    libsm6 \
    libxext6 \
    libxrender1 \
    libxkbcommon0 \
    libdbus-1-3 \
    && rm -rf /var/lib/apt/lists/*

# Copy the entire project first
COPY . /app

# Install Python dependencies from backend/requirements.txt
RUN python -m pip install --no-cache-dir --upgrade pip && \
    python -m pip install --no-cache-dir -r backend/requirements.txt

# Use PORT env if provided by the host
ENV PORT=8000
EXPOSE 8000

CMD ["uvicorn", "backend.app:app", "--host", "0.0.0.0", "--port", "8000"]
