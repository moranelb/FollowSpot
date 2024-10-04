# Use an older Python runtime (3.7) as a parent image
FROM python:3.7-slim

# Set the working directory
WORKDIR /app

# Install PostgreSQL client utilities and dependencies
RUN apt-get update && apt-get install -y \
    postgresql-client \
    postgresql-common \
    postgresql && \
    rm -rf /var/lib/apt/lists/*

# Copy the requirements file and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Expose the port the app runs on
EXPOSE 5000

# Set environment variables
ENV FLASK_APP=server.py
ENV DATABASE_URL=postgres://postgres:password@db:5432/appdb

# Command to run the app
CMD ["flask", "run", "--host=0.0.0.0"]
