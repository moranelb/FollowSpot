# Use Python 3.7 as the base image
FROM python:3.7-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the requirements file and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code into the working directory
COPY . .

# Expose the Flask app port
EXPOSE 5000

# Set environment variables
ENV FLASK_APP=server.py
ENV FLASK_ENV=development
ENV DATABASE_URL=postgresql://postgres:password@db:5432/mydatabase

# Ensure the database connection is ready before starting the app
CMD ["flask", "run", "--host=0.0.0.0"]
