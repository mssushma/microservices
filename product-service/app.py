from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/products')
def products():
    return jsonify({
        "service": "product-service",
        "products": [
            "Laptop",
            "Phone",
            "Monitor"
        ]
    })

@app.route('/health')
def health():
    return {"status": "UP"}

app.run(host="0.0.0.0", port=5000)
