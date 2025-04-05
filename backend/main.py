# from fastapi import FastAPI, File, UploadFile
# import cv2
# import numpy as np
# import torch
# from ultralytics import YOLO

# app = FastAPI()

# @app.get("/")
# def home():
#     return {"message": "FastAPI is running"}

# # Load YOLO model (Ensure the model path is correct)
# model = YOLO("currency_model.pt")  # Make sure this file exists!

# @app.post("/predict_currency")
# async def predict_currency(file: UploadFile = File(...)):
#     try:
#         contents = await file.read()
#         nparr = np.frombuffer(contents, np.uint8)
#         img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

#         results = model(img)  # YOLOv8 detection

#         # Check if objects were detected
#         if results and len(results[0].boxes) > 0:
#             # Extract the top detected label
#             class_id = int(results[0].boxes.cls[0])  # Get class index
#             detected_currency = results[0].names[class_id]  # Get class name
#             return {"currency": detected_currency}
#         else:
#             return {"currency": "No currency detected"}

#     except Exception as e:
#         return {"error": str(e)}
# if __name__ == "__main__":
#     import uvicorn
#     uvicorn.run(app, host="0.0.0.0", port=8000)
from flask import Flask, request, jsonify
import cv2
import numpy as np
from ultralytics import YOLO
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # Allow cross-origin requests (important for mobile frontend)

# Load your trained model
model = YOLO("currency_model.pt")

@app.route('/')
def home():
    return "Flask is running"

@app.route('/predict_currency', methods=['POST'])
def predict_currency():
    if 'file' not in request.files:
        return jsonify({'error': 'No file uploaded'}), 400

    file = request.files['file']
    img_bytes = file.read()
    nparr = np.frombuffer(img_bytes, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

    results = model(img)
    if results:
        try:
            currency = results[0].names[int(results[0].probs.top1)]
        except:
            currency = "Detected but label not found"
        return jsonify({'currency': currency})
    return jsonify({'currency': 'No currency detected'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
