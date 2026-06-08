FROM python:3.11-slim

WORKDIR /app

# Install system dependencies needed for Python imaging and OpenCV
# Use only packages available in Debian Trixie
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libsm6 \
    libxext6 \
    libxrender-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy only Python dependency definitions first to cache installs
COPY requirements.txt ./requirements.txt
RUN python -m pip install --no-cache-dir --upgrade pip && \
    python -m pip install --no-cache-dir -r requirements.txt

# Copy the backend and other project files
COPY . /app

# Use PORT env if provided by the host
ENV PORT=8000
EXPOSE 8000

CMD ["uvicorn", "backend.app:app", "--host", "0.0.0.0", "--port", "8000"]
