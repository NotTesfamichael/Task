# app.py - Simple Flask API
from flask import Flask, jsonify
import redis
import os

app = Flask(__name__)

redis_client = redis.Redis(
    host=os.getenv('REDIS_HOST', 'redis'),
    port=6379,
    decode_responses=True
)

@app.route('/health')
def health():
    try:
        redis_client.ping()
        return jsonify({"status": "healthy"}), 200
    except Exception as e:
        return jsonify({"status": "unhealthy", "error": str(e)}), 503

@app.route('/api/counter')
def counter():
    count = redis_client.incr('api_calls')
    return jsonify({"calls": count}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)