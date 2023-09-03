"""
File: app.py
Description: FastAPI server to handle podcast transcription requests.
             This file sets up the FastAPI application and defines the endpoint
             for transcribing chats. The transcription is performed by invoking
             a function from a Modal parent app.

Steps to run and test the server:
- Run the server using the command (remember, navigate to the directory containing the `parent` folder)
        uvicorn parent.app:app --reload
- Test the endpoint by navigating to the Swagger UI at http://127.0.0.1:8000/docs
    > url https://parent-audio.s3.us-east-2.amazonaws.com/El+Terrible+Juan+Cafe%CC%81.m4a
"""

from fastapi import FastAPI, File, UploadFile
import boto3
from dotenv import load_dotenv
import modal
import os
from pathlib import Path

# Load environment variables from .env file
load_dotenv()

# Read environment variables
AWS_ACCESS_KEY_ID = os.getenv("AWS_ACCESS_KEY_ID")
AWS_SECRET_ACCESS_KEY = os.getenv("AWS_SECRET_ACCESS_KEY")
AWS_REGION = os.getenv("AWS_REGION")
S3_BUCKET_NAME = os.getenv("S3_BUCKET_NAME")

app = FastAPI()

s3 = boto3.client('s3',
                  aws_access_key_id=AWS_ACCESS_KEY_ID,
                  aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
                  region_name=AWS_REGION)

@app.post("/upload_audio_file/")
async def upload_audio_file(file: UploadFile = File(...)):
    file_content = file.file.read()

    s3.put_object(
        Bucket=S3_BUCKET_NAME,
        Key=f'audio_files/{file.filename}',
        Body=file_content
    )

    file_url = f"https://{S3_BUCKET_NAME}.s3.{AWS_REGION}.amazonaws.com/audio_files/{file.filename}"
    
    return {"file_url": file_url}

@app.get("/transcribe_and_dadvise/")
def transcribe_and_dadvise(url: str = None):
    """
    Endpoint to transcribe an audio file from a given URL and subsequently generate 
    parenting advice based on the transcription. This function accomplishes both tasks 
    by invoking two different functions deployed on Modal.

    Parameters:
    url (str): URL of the audio file to be transcribed.

    Returns:
    dict: A dictionary containing the advice text generated based on the transcription.
    
    Workflow:
    1. Transcribes the audio file using the 'get_transcribed_chat' function from Modal.
    2. Generates parenting advice based on the transcription using the 'get_parent_advice' function from Modal.
    """    
    # Replace this with actual code to transcribe remote file
    transcription = modal.Function.lookup("parent-app", "get_transcribed_chat").call(file_url=url)['text']
        
    # Generate advice based on transcription
    advice = modal.Function.lookup("parent-app", "get_parent_advice").call(chat_transcript=transcription)

    return {"advice": advice}

# SCRATCH
# response = {
#     "text": transcription,
#     "file_url": file_url,
#     "local_path": local_path
# }


# from fastapi.responses import FileResponse
# import shutil
# from fastapi.responses import JSONResponse
#
# @app.get("/list_files")
# def list_files():
#     try:
#         upload_dir = "parent/audio_files"  # Replace with your upload directory
#         if not os.path.exists(upload_dir):
#             return JSONResponse(content={"error": "Directory does not exist"}, status_code=404)
#         files = os.listdir(upload_dir)
#         return {"files": files}
#     except PermissionError:
#         return JSONResponse(content={"error": "Permission denied"}, status_code=403)
#     except Exception as e:
#         return JSONResponse(content={"error": str(e)}, status_code=500)

# @app.post("/upload/")
# async def upload_audio_file(file: UploadFile = File(...)):
#     """
#     Endpoint to upload an audio file.

#     Parameters:
#     file (UploadFile): The audio file uploaded by the user.

#     Returns:
#     dict: Information about the uploaded file.
#     """

#     # Create a temporary file and save the uploaded content to this file
#     temp_file = Path(f"parent/audio_files/{file.filename}")
#     with temp_file.open("wb") as buffer:
#         shutil.copyfileobj(file.file, buffer)
    
#     return {"file_name": file.filename, "status": "File uploaded successfully"}