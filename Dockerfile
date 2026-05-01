FROM python:3.11-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
        libgomp1 \
        libglib2.0-0 \
        libsndfile1 \
        curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
 && pip install --no-cache-dir -r requirements.txt

COPY . .

# Create data directory for any local files (though we use Supabase as primary DB)
RUN mkdir -p /data /app/logs

# Set proper permissions
RUN chmod +x start.sh

EXPOSE 8000

# Use CMD with exec form to ensure environment variables are passed correctly
CMD ["sh", "start.sh"]
