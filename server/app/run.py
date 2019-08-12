import base64
import json

from flask import Flask, escape, request
app = Flask(__name__)

users = {}

with open("ben.png", "rb") as image:
    ben = base64.b64encode(image.read())
with open("lewis.png", "rb") as image:
    lewis = base64.b64encode(image.read())


@app.route('/users', methods=["GET"])
def get_users():
    return json.dumps(str(users)), 200


@app.route('/users', methods=["POST"])
def create_user():
    data = request.get_json(force=True)
    users[data["name"]] = {
        "long": data["long"],
        "lat": data["long"],
        "image": ben if data["name"] == "ben" else lewis,
        "name": data["name"],
    }
    return "", 201


if __name__ == '__main__':
    app.run()
