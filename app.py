from flask import Flask
from flask_cors import CORS
from config.default import DefaultConfig

def create_app():
    app = Flask(__name__)
    # 加载默认配置
    app.config.from_object(DefaultConfig)
    # 跨域支持（开发时使用，生产环境可以做更细粒度控制）
    CORS(app)

    # 注册路由蓝本
    from routes import register_routes
    register_routes(app)

    return app

if __name__ == '__main__':
    app = create_app()
    app.run(debug=True, port=5000)
