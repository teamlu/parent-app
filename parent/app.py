"""
File: app.py
Description: FastAPI server to handle podcast transcription requests.
             This file sets up the FastAPI application and defines the endpoint
             for transcribing chats with mock response.

Steps to run and test the server:
- Run the server using the command (remember, navigate to the directory containing the `parent` folder)
        uvicorn parent.app:app --reload
- Test the endpoint by navigating to:
    http://127.0.0.1:8000/transcribe?rss_url=test_rss&local_path=test_path
    or use the Swagger UI at:
    http://127.0.0.1:8000/docs
"""

from fastapi import FastAPI

app = FastAPI()

@app.get("/transcribe")
def transcribe_chat(file_url: str, local_path: str):
    """
    Endpoint to transcribe chat given an file URL and local path.

    Parameters:
    file_url (str): URL of the chat.
    local_path (str): Local path to save the transcription.

    Returns:
    dict: A mock response containing transcribed text, RSS URL, and local path.
    """

    # This is a mock response that will be returned when this endpoint is called.
    # In the actual implementation, this would be replaced with code that performs
    # the transcription and returns the result.
    mock_response = {
        "text": "This is a transcribed text from the chat.",
        "rss_url": file_url,
        "local_path": local_path
    }

    return mock_response
