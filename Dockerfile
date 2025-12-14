FROM python:3.11-slim

WORKDIR /app

# Create virtual environment
RUN python -m venv /app/venv

# Activate virtual environment and install dependencies
ENV PATH="/app/venv/bin:$PATH"
RUN /app/venv/bin/pip install --no-cache-dir --upgrade pip

COPY requirements.txt .
RUN /app/venv/bin/pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 5000

# Run the app using the virtual environment's Python
CMD ["/app/venv/bin/python", "app.py"]