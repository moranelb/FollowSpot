# Use Python 3.7 slim as a base image
FROM python:3.7-slim

# Set the working directory
WORKDIR /app

# Install PostgreSQL client utilities and dependencies
RUN apt-get update && apt-get install -y \
    postgresql-client \
    postgresql-common \
    postgresql && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root user for PostgreSQL operations
RUN useradd -m postgresuser

# Set ownership of the app directory to the non-root user
RUN chown -R postgresuser /app

# Switch to the non-root user
USER postgresuser

# Add .local/bin to PATH so locally installed Python packages are found
ENV PATH="/home/postgresuser/.local/bin:$PATH"

# Copy the requirements file and install dependencies
COPY requirements.txt . 
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Expose the port the app runs on
EXPOSE 5000

# Command to run the app with PostgreSQL readiness check
CMD ["/bin/sh", "-c", "while ! pg_isready -h db -p 5432 -U appuser; do echo waiting for database; sleep 2; done && flask run --host=0.0.0.0"]
