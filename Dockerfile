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

# Create a non-root user for PostgreSQL operations
RUN useradd -m postgresuser

# Copy the wait-for-postgres.sh script and set permissions while still root
COPY wait-for-postgres.sh /app/wait-for-postgres.sh
RUN chmod +x /app/wait-for-postgres.sh

# Set ownership of the app directory and the script to the non-root user
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

# Set environment variables
ENV FLASK_APP=server.py
ENV DATABASE_URL=postgres://postgres:password@db:5432/appdb

# Command to run the app, using wait-for-postgres.sh to ensure DB is ready
CMD ["/app/wait-for-postgres.sh", "flask", "run", "--host=0.0.0.0"]
