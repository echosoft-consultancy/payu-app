import base64
import json

from flask import Flask, escape, request
app = Flask(__name__)

users = []

with open("ben.png", "rb") as image:
    ben = str(base64.b64encode(image.read()))
with open("lewis.png", "rb") as image:
    lewis = str(base64.b64encode(image.read()))


@app.route('/users', methods=["GET"])
def get_users():
    return json.dumps(users), 200


@app.route('/users', methods=["POST"])
def create_user():
    data = request.get_json(force=True)
    if len(users) == 0:
        users.append({
            "lat": data["lat"],
            "long": data["long"],
            "image": ben if data["name"] == "ben" else lewis,
            "name": data["name"],
        })
        return "", 201

    for i, user in enumerate(users):
        if data["name"] == user["name"]:
            user["lat"] = data["lat"]
            user["long"] = data["long"]
            return "", 201

    return "", 400


if __name__ == '__main__':
    app.run("0.0.0.0")
