from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/users')
def users():
    return jsonify({
        "service": "user-service",
        "users": ["John", "David"]
    })

@app.route('/health')
def health():
    return {"status": "UP"}

app.run(host="0.0.0.0", port=5000)
