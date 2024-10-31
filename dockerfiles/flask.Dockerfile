FROM python:3.11-alpine

# Set up environment variables for Python
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Create and set the working directory
WORKDIR /app

# Copy only the requirements file first to leverage Docker caching
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the entire application code
COPY . .

# Expose the port your application will run on
EXPOSE 8000

# Specify the command to run on container start
# CMD ["gunicorn", "--bind", "0.0.0.0:8000", "main:create_app()"]
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--timeout", "120", "main:create_app()"]

# main.py
# from app import api_v1, connect_mongo
# from app import APIConstants

# from flask import Flask
# from flask_restful import Api
# from flasgger import Swagger
# from flask_cors import CORS

# def create_app():
#     app = Flask(__name__)
#     api = Api(app)
#     swagger = Swagger(app)
#     CORS(app)

#     app.register_blueprint(api_v1, url_prefix='/api/v1')

#     # test config
#     connect_mongo()
#     # TODO: test Jira connection
#     # TODO: test Qdrant connection
#     # TODO: other tests here

#     return app

# if __name__ == "__main__":
#     app = create_app()
#     app.run(
#         debug=True if APIConstants.API_RUN_MODE==APIConstants.DEVELOPMENT else False,
#         host=APIConstants.API_HOST,
#         port=8000
#     )