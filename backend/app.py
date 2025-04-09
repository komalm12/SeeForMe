# from flask import Flask, request, jsonify
# import easyocr
# from flask_cors import CORS
# import os

# app = Flask(__name__)
# CORS(app)  # Enable CORS for all routes

# # Initialize EasyOCR with English and Hindi
# reader = easyocr.Reader(['en', 'hi',], gpu=False)

# @app.route('/ocr', methods=['POST'])
# def ocr():
#     print("Received OCR request")
#     if 'image' not in request.files:
#         return jsonify({'error': 'No image uploaded'}), 400

#     image = request.files['image']
#     image_path = 'temp.jpg'
#     image.save(image_path)

#     result = reader.readtext(image_path, detail=0)
#     extracted_text = '\n'.join(result)

#     return jsonify({'text': extracted_text})

# if __name__ == '__main__':
#     app.run(host='0.0.0.0', port=5000)

from flask import Flask, request, jsonify
import pytesseract
from PIL import Image
import io
import numpy as np
from ultralytics import YOLO

app = Flask(__name__)

# Load YOLO model once
currency_model = YOLO("models/best.pt")  # Replace with your actual model

# -------------------------------
# 📝 OCR Route: Scan & Read
# -------------------------------
@app.route('/ocr', methods=['POST'])
def scan_and_read():
    if 'image' not in request.files:
        return jsonify({'error': 'No image uploaded'}), 400

    file = request.files['image']
    try:
        image = Image.open(io.BytesIO(file.read()))
        text = pytesseract.image_to_string(image)
        return jsonify({'text': text.strip()})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ----------------------------------
# 💰 Currency Recognition Route
# ----------------------------------
@app.route('/currency', methods=['POST'])
def recognize_currency():
    if 'image' not in request.files:
        return jsonify({'error': 'No image uploaded'}), 400

    file = request.files['image']
    try:
        image = Image.open(io.BytesIO(file.read())).convert('RGB')
        image_np = np.array(image)

        # Run YOLO prediction
        results = currency_model(image_np)[0]

        predictions = []
        for result in results.boxes.data.tolist():
            x1, y1, x2, y2, conf, cls_id = result
            label = currency_model.names[int(cls_id)]
            predictions.append({
                "label": label,
                "confidence": round(conf, 2),
                "box": [x1, y1, x2, y2]
            })

        return jsonify({'predictions': predictions})

    except Exception as e:
        return jsonify({'error': str(e)}), 500

# -------------------------------
# Root Route
# -------------------------------
@app.route('/')
def home():
    return "Flask API is running with OCR and Currency Detection!"

# -------------------------------
# Run Flask App
# -------------------------------
if __name__ == '__main__':
    app.run(debug=True)
