FROM python:3.11-slim

# Set environment variables
ENV FLASK_APP=crudapp.py
ENV FLASK_RUN_HOST=0.0.0.0
ENV FLASK_RUN_PORT=80
ENV FLASK_ENV=production

# Set workdir
WORKDIR /app

# Copy files
COPY . /app

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Setup the database
RUN flask db init || true
RUN flask db migrate -m "init" || true
RUN flask db upgrade || true

# Expose the app on port 80
EXPOSE 80

# Run the app
CMD ["flask", "run", "--host=0.0.0.0", "--port=80"]
