FROM python:3.9-slim-buster
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY bitcoin_monitor.py .
EXPOSE 5000
CMD  ["python", "bitcoin_monitor.py"]
