# # for currency & onject detection
# from flask import Flask, request, jsonify
# from flask_cors import CORS
# from ultralytics import YOLO
# from PIL import Image
# import requests

# app = Flask(__name__)
# CORS(app)

# # Load your models
# object_model = YOLO("yolov8x.pt")       # Replace with your object detection model path
# model = YOLO("models/best.pt")   # Replace with your currency recognition model path

# @app.route("/detect", methods=["POST"])
# def detect_objects():
#     if 'image' not in request.files:
#         return jsonify({"error": "No image uploaded"}), 400

#     image_file = request.files['image']
#     image = Image.open(image_file.stream).convert('RGB')
#     results = object_model.predict(image)

#     # detections = []
#     detected_labels = []
#     for r in results:
#         for box in r.boxes:
#             label = r.names[int(box.cls[0])]
#             if label not in detected_labels:
#                 detected_labels.append(label)
#     # for result in results:
#     #     for box in result.boxes:
#     #         detections.append({
#     #             "label": object_model.names[int(box.cls[0])],
#     #             # "confidence": float(box.conf[0]),
#     #             # "bbox": box.xyxy[0].tolist()  # [x1, y1, x2, y2]
#     #         })

#     return jsonify({"detections": detected_labels})


# @app.route("/recognize", methods=["POST"])
# def recognize_currency():
#     if 'image' not in request.files:
#         return jsonify({"error": "No image uploaded"}), 400

#     image_file = request.files['image']
#     image = Image.open(image_file.stream).convert('RGB')
#     results = model.predict(image)

#     detections = []
#     for result in results:
#         for box in result.boxes:
#             detections.append({
#                 "label": model.names[int(box.cls[0])],
#                 "confidence": float(box.conf[0]),
#                 "bbox": box.xyxy[0].tolist()
#             })

#     # ✅ Return top prediction only
#     top = max(detections, key=lambda x: x['confidence'], default=None)
#     if top:
#         return jsonify({
#             "currency": top["label"],
#             "confidence": top["confidence"]
#         })

#     return jsonify({"currency": "Unknown", "confidence": 0.0})
# if __name__ == "__main__":
#     app.run(debug=True, host="0.0.0.0", port=5000)
from flask import Flask, request, jsonify
from flask_cors import CORS
from ultralytics import YOLO
from PIL import Image
from roboflow import Roboflow
import os

app = Flask(__name__)
CORS(app)

# Load YOLOv8 object detection model (local)
object_model = YOLO("yolov8x.pt")  # Replace with your object detection model path

# Initialize Roboflow (currency detection)
rf = Roboflow(api_key="AZkWitHZ7tFt8yHbaPks")  # Replace with your Roboflow API key
project = rf.workspace().project("currency-detection-cgpjn")  # Your project ID
model = project.version(1).model

# ========== Object Detection (Local YOLOv8) ==========
@app.route("/detect", methods=["POST"])
def detect_objects():
    if 'image' not in request.files:
        return jsonify({"error": "No image uploaded"}), 400

    image_file = request.files['image']
    image = Image.open(image_file.stream).convert('RGB')

    results = object_model.predict(image)

    detected_labels = []
    for r in results:
        for box in r.boxes:
            label = r.names[int(box.cls[0])]
            if label not in detected_labels:
                detected_labels.append(label)

    return jsonify({"detections": detected_labels})


# ========== Currency Detection (Roboflow Hosted API) ==========
@app.route('/predict', methods=['POST'])
def predict_currency():
    if 'image' not in request.files:
        return jsonify({'error': 'No image uploaded'}), 400

    image = request.files['image']
    image.save("temp.jpg")

    prediction = model.predict("temp.jpg", confidence=40, overlap=30).json()
    os.remove("temp.jpg")

    return jsonify(prediction)


# ========== Run the App ==========
if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000)



#for currency detection
# from flask import Flask, request, jsonify
# from roboflow import Roboflow
# import base64
# import os

# app = Flask(__name__)

# # Initialize Roboflow
# rf = Roboflow(api_key="AZkWitHZ7tFt8yHbaPks")
# project = rf.workspace().project("cmoney-detection-qbxqs")
# model = project.version(1).model

# @app.route('/predict', methods=['POST'])
# def predict():
#     if 'image' not in request.files:
#         return jsonify({'error': 'No image uploaded'}), 400

#     image = request.files['image']
#     image.save("temp.jpg")

#     prediction = model.predict("temp.jpg", confidence=40, overlap=30).json()
#     os.remove("temp.jpg")

#     return jsonify(prediction)

# if __name__ == '__main__':
#     app.run(host="0.0.0.0", port=5000)



























































#for distance but not working properly

# from flask import Flask, request, jsonify
# from ultralytics import YOLO
# from PIL import Image
# from known_widths import KNOWN_WIDTHS # Dict with real-world object widths
# import io

# app = Flask(__name__)
# model = YOLO("yolov8n.pt")  # Pre-trained YOLOv8 model

# # Assume a constant focal length (you can calibrate this with known distance)
# FOCAL_LENGTH = 615  # You can adjust this based on calibration

# @app.route("/detect", methods=["POST"])
# def detect_objects():
#     if 'image' not in request.files:
#         return jsonify({"error": "No image found"}), 400

#     image = Image.open(request.files['image'].stream)
#     results = model(image)

#     detections = []

#     for r in results:
#         for box in r.boxes:
#             cls_id = int(box.cls[0])
#             label = r.names[cls_id]

#             # Get box width in pixels
#             x1, y1, x2, y2 = box.xyxy[0]
#             box_width_px = x2 - x1

#             # Get known width for object (if available)
#             known_width = KNOWN_WIDTHS.get(label)

#             if known_width and box_width_px > 0:
#                 distance = round((known_width * FOCAL_LENGTH) / box_width_px.item(), 2)
#                 distance_text = f"{distance} meters"
#             else:
#                 distance_text = "Unknown"

#             detections.append({
#                 "label": label,
#                 "confidence": round(box.conf[0].item(), 2),
#                 "distance": distance_text
#             })

#     return jsonify({"detections": detections})


