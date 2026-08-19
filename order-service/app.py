from flask import Flask, jsonify
import requests

app = Flask(__name__)

@app.route('/orders')
def orders():

    products = requests.get(
        "http://product-service/products"
    ).json()

    return jsonify({
        "service": "order-service",
        "orders": [
            "ORDER-1001"
        ],
        "product-service-response": products
    })

@app.route('/health')
def health():
    return {"status": "UP"}

app.run(host="0.0.0.0", port=5000)
