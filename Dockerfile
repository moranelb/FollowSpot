# Use Python 3.7-slim as a base image
FROM python:3.7-slim

# Set working directory inside the container
WORKDIR /app

# Install PostgreSQL client and dependencies
RUN apt-get update && apt-get install -y \
    postgresql-client \
    postgresql-common \
    postgresql && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root user for PostgreSQL operations
RUN useradd -m postgresuser

# Change ownership of the /app directory to the non-root user
RUN chown -R postgresuser /app

# Switch to the non-root user
USER postgresuser

# Add .local/bin to PATH for locally installed Python packages
ENV PATH="/home/postgresuser/.local/bin:$PATH"

# Copy the requirements file and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the app code to the container
COPY . .

# Expose the application port
EXPOSE 5000

# Set environment variables
ENV FLASK_APP=server.py
ENV DATABASE_URL=postgresql://postgres:password@db:5432/mydatabase  # Correctly formatted

# Run the Flask app
CMD ["flask", "run", "--host=0.0.0.0"]
