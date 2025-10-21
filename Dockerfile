# For more information, please refer to https://aka.ms/vscode-docker-python
# Use a slim and specific version of the Python base image
FROM python:3.9-slim

# Set the working directory for the entire build process
WORKDIR /app

# Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1

# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1

# --- INSTALLATION STEP ---
# Copy only the necessary files for installation first.
# This leverages Docker's layer caching. If these files don't change,
# Docker won't re-run the installation on subsequent builds, making them much faster.
COPY requirements.txt .
COPY setup.py .

# Now, install pip requirements. This works because setup.py is present for the "-e ." command.
RUN python -m pip install -r requirements.txt

# --- APPLICATION CODE STEP ---
# Copy the rest of your application code into the working directory
COPY . .

# --- SECURITY & RUN STEP ---
# Creates a non-root user and gives it ownership of the /app folder
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

# Expose the port the app runs on
EXPOSE 5000

# The command to run your application using Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "wsgi:app"]
