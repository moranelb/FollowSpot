# Use Python 3.7-slim as the base image
FROM python:3.7-slim

# Set working directory
WORKDIR /app

# Install PostgreSQL client and dependencies
RUN apt-get update && apt-get install -y \
    postgresql-client \
    postgresql-common \
    postgresql && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN useradd -m postgresuser

# Change ownership of the /app directory
RUN chown -R postgresuser /app

# Switch to non-root user
USER postgresuser

# Add .local/bin to PATH
ENV PATH="/home/postgresuser/.local/bin:$PATH"

# Copy requirements.txt and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code
COPY . .

# Expose the application port
EXPOSE 5000

# Set environment variables
ENV FLASK_APP=server.py
ENV DATABASE_URL=postgresql://postgres:password@db:5432/mydatabase  # Ensure this matches docker-compose.yml

# Run Flask app
CMD ["flask", "run", "--host=0.0.0.0"]
