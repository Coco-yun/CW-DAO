from flask import Blueprint, jsonify, current_app

secret_bp = Blueprint('secret', __name__, url_prefix='/api/secret')

@secret_bp.route('/keys', methods=['GET'])
def get_keys():
    key1 = current_app.config.get('API_KEY_1')
    key2 = current_app.config.get('API_KEY_2')
    return jsonify({"api_key_1": key1, "api_key_2": key2})
