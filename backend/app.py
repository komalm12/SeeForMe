from flask import Flask, request, jsonify
from flask_cors import CORS
from ultralytics import YOLO
from PIL import Image

app = Flask(__name__)
CORS(app)

# Load your models
object_model = YOLO("yolov8n.pt")       # Replace with your object detection model path
currency_model = YOLO("models/best.pt") # Replace with your currency recognition model path

@app.route("/detect", methods=["POST"])
def detect_objects():
    if 'image' not in request.files:
        return jsonify({"error": "No image found"}), 400

    # Open the image
    image = Image.open(request.files['image'].stream)
    
    # Perform object detection
    results = object_model(image)

    detected_labels = []
    for result in results:
        for box in result.boxes:
            # Ensure you are accessing the correct index for labels
            label = result.names[int(box.cls[0].item())]  # Using .item() to extract the scalar value from the tensor
            if label not in detected_labels:
                detected_labels.append(label)

    return jsonify({"detections": detected_labels})

@app.route("/recognize", methods=["POST"])
def recognize_currency():
    if 'image' not in request.files:
        return jsonify({"error": "No image uploaded"}), 400

    # Open the image for currency recognition
    image_file = request.files['image']
    image = Image.open(image_file.stream).convert('RGB')

    # Perform currency recognition
    results = currency_model.predict(image)

    detections = []
    for result in results:
        for box in result.boxes:
            detections.append({
                "label": currency_model.names[int(box.cls[0].item())],  # Using .item() for tensor to int
                "confidence": float(box.conf[0]),
                "bbox": box.xyxy[0].tolist()
            })

    # Return the top prediction based on confidence
    top = max(detections, key=lambda x: x['confidence'], default=None)
    if top:
        return jsonify({
            "currency": top["label"],
            "confidence": top["confidence"]
        })

    return jsonify({"currency": "Unknown", "confidence": 0.0})

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)


# from flask import Flask, request, jsonify
# from ultralytics import YOLO
# from PIL import Image
# import io
# from known_widths import KNOWN_WIDTHS

# app = Flask(__name__)
# model = YOLO("yolov8n.pt")  # No training needed

# # @app.route("/detect", methods=["POST"])
# # def detect_objects():
# #     if 'image' not in request.files:
# #         return jsonify({"error": "No image found"}), 400

# #     image = Image.open(request.files['image'].stream)
# #     results = model(image)

# #     detected_labels = []
# #     for r in results:
# #         for box in r.boxes:
# #             label = r.names[int(box.cls[0])]
# #             if label not in detected_labels:
# #                 detected_labels.append(label)

# #     return jsonify({"detections": detected_labels})
    

# if __name__ == "__main__":
#     app.run(host="0.0.0.0", port=5000, debug=True)







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

# if __name__ == "__main__":
#     app.run(host="0.0.0.0", port=5000, debug=True)
