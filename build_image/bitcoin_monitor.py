import threading
import time
from typing import List, Optional
from flask import Flask, render_template_string
import requests

app = Flask(__name__)

HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Bitcoin Price Tracker</title>
    <meta http-equiv="refresh" content="60">
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; background-color: #1e1e1e; color: #eee; }
        h1 { color: #ffc107; }
        pre { background-color: #333; padding: 15px; border-radius: 5px; white-space: pre-wrap; }
    </style>
</head>
<body>
    <h1>📈 Bitcoin Price Tracker (updated every 60s)</h1>
    <pre>{{ log_output }}</pre>
</body>
</html>
"""

class BitcoinPriceTracker:
    def __init__(self, fetch_interval: int = 60, history_size: int = 10, max_log_lines: int = 100) -> None:
        self.fetch_interval = fetch_interval
        self.history_size = history_size
        self.max_log_lines = max_log_lines
        self.price_history: List[float] = []
        self.counter = 0
        self.log_lines: List[str] = []

    def fetch_price(self) -> Optional[float]:
        headers = {
            "User-Agent": "BTCPriceTracker/1.0 (contact: email@example.com)"
        }
        try:
            response = requests.get(
                "https://api.coingecko.com/api/v3/simple/price",
                params={"ids": "bitcoin", "vs_currencies": "usd"},
                headers=headers,
                timeout=10
            )
            response.raise_for_status()
            return response.json()["bitcoin"]["usd"]
        except:
            return None  # Silently fail, do not log errors

    def add_price(self, price: float) -> None:
        self.price_history.append(price)
        if len(self.price_history) > self.history_size:
            self.price_history.pop(0)

    def calculate_average(self) -> Optional[float]:
        if len(self.price_history) < self.history_size:
            return None
        return sum(self.price_history) / self.history_size

    def append_log(self, line: str) -> None:
        timestamp = time.strftime('%Y-%m-%d %H:%M:%S')
        self.log_lines.append(f"[{timestamp}] {line}")
        if len(self.log_lines) > self.max_log_lines:
            self.log_lines.pop(0)

    def run_tracker(self) -> None:
        while True:
            price = self.fetch_price()
            if price is not None:
                self.add_price(price)
                self.counter += 1
                self.append_log(f"BTC Price: ${price:.2f}")
                if self.counter % self.history_size == 0:
                    avg = self.calculate_average()
                    if avg:
                        self.append_log(f"📊 10-Minute Average: ${avg:.2f}")
            time.sleep(self.fetch_interval)

tracker = BitcoinPriceTracker()

@app.route("/")
def home():
    return render_template_string(HTML_TEMPLATE, log_output="\n".join(tracker.log_lines).strip())

if __name__ == "__main__":
    thread = threading.Thread(target=tracker.run_tracker, daemon=True)
    thread.start()
    print("🌐 Flask web server running at http://localhost:5000")
    app.run(host="0.0.0.0", port=5000)
