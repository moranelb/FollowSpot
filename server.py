"""Server for FollowSpot"""
from flask import (Flask, jsonify, render_template, request, flash, session, redirect)
import crud
import os
import logging  # Import the logging module
from twilio.rest import Client
import cloudinary.uploader
import cloudinary.api
from cloudinary.utils import cloudinary_url
from flask_cors import CORS, cross_origin
from model import connect_to_db, db, User, Audition, Project, Media
from datetime import datetime

# Set up basic logging configuration
logging.basicConfig(level=logging.DEBUG)

#import custom stuff
from utils.cipher import hashed

app = Flask(__name__)
CORS(app)
app.secret_key = os.environ.get("SECRET_KEY", "followspot")
connect_to_db(app)

twilio_account_sid = os.environ.get('twilio_account_sid')
twilio_auth_token = os.environ.get('twilio_auth_token')
cloud_name = os.environ.get('cloud_name')
cloud_api_key = os.environ.get('cloud_api_key')
cloud_api_secret = os.environ.get('cloud_api_secret')

####################################HOME############################################

@app.route('/')
def show_home():
    """Shows homepage. Lets users with existing accounts login"""
    logging.debug("Rendering home page.")
    return render_template('home.html')

# ... (rest of your routes remain unchanged)

#################################RUN###################################################

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
