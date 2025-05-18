from flask import Blueprint, jsonify

# 定义蓝本，路由前缀为 /api/items
status_bp = Blueprint('statue', __name__, url_prefix='/api/status')

@status_bp.route('', methods=['GET'])
def get_items():
    # 模拟数据返回
    status_info = {
        "status": "running",
        "message": "Service is active"
    }
    return jsonify(status_info), 200
