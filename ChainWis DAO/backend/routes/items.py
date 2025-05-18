from flask import Blueprint, jsonify

# 定义蓝本，路由前缀为 /api/items
items_bp = Blueprint('items', __name__, url_prefix='/api/items')

@items_bp.route('', methods=['GET'])
def get_items():
    # 模拟数据返回
    data = {
        "items": [
            {"id": 1, "name": "Item One"},
            {"id": 2, "name": "Item Two"}
        ]
    }
    return jsonify(data), 200
