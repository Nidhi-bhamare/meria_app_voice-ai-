FROM python:3.10-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    g++ \
    gcc \
    make \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

# Install Python dependencies in controlled order
RUN pip install --upgrade pip && \
    pip install --no-cache-dir "Cython>=0.29.0" && \
    pip install --no-cache-dir "youtokentome==1.0.6" && \
    pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["uvicorn", "backend:app", "--host", "0.0.0.0", "--port", "8000"]