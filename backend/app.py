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
























































