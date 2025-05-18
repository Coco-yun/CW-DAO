from .items import items_bp
from .users import users_bp
from .secret import secret_bp
from .status import status_bp

def register_routes(app):
    app.register_blueprint(items_bp)
    app.register_blueprint(users_bp)
    app.register_blueprint(secret_bp)
    app.register_blueprint(status_bp)
