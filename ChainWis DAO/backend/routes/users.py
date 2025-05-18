from flask import Blueprint, jsonify

# 定义蓝本，路由前缀为 /api/users
users_bp = Blueprint('users', __name__, url_prefix='/api/users')

@users_bp.route('', methods=['GET'])
def get_users():
    # 模拟数据返回
    data = {
        "users": [
            {"id": 1, "username": "alice"},
            {"id": 2, "username": "bob"}
        ]
    }
    return jsonify(data), 200
