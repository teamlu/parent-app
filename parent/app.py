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

from fastapi import FastAPI
import modal

app = FastAPI()

@app.get("/main")
def transcribe_and_dadvise(url: str):
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

    # Invoke the 'get_transcribed_chat' function from Modal to perform transcription
    f_transcribe = modal.Function.lookup("parent-app", "get_transcribed_chat")
    transcription = f_transcribe.call(file_url=url)['text']

    # Invoke the 'get_parent_advice' function from Modal to generate advice
    f_advise = modal.Function.lookup("parent-app", "get_parent_advice")
    advice = f_advise.call(chat_transcript=transcription)

    return {"advice": advice}

# SCRATCH
# response = {
#     "text": transcription,
#     "file_url": file_url,
#     "local_path": local_path
# }