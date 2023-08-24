"""
File: transcriber.py
Description: This file tests the following methods:
             1. download_file: Downloads a file from a given URL and saves it locally.
             2. download_whisper: Downloads the Whisper model for transcription.
             3. get_transcribed_chat: Transcribes a chat from a given URL using the Whisper model.
             4. main: Main entrypoint that triggers the transcription function.

Steps: You can invoke either function from the command line with - be sure to uncomment `main()`:
       > modal run transcriber.py --file-url https://parent-audio.s3.us-east-2.amazonaws.com/El+Terrible+Juan+Cafe%CC%81.m4a
       
       If you're satisfied, deploy it with:
       > modal deploy backend.py
"""

import modal
import requests

def download_file(url, local_path):
    with requests.get(url, stream=True) as r:
        r.raise_for_status()
        with open(local_path, 'wb') as f:
            for chunk in r.iter_content(chunk_size=8192):
                f.write(chunk)
    print(f"File downloaded to {local_path}")

def download_whisper():
    # Load the Whisper model
    import whisper
    print("Download the Whisper model")

    # Perform download only once and save to Container storage
    whisper._download(whisper._MODELS["medium"], '/whisper/', False)

stub = modal.Stub("parent-app")
parent_image = modal.Image.debian_slim().pip_install(
    "https://github.com/openai/whisper/archive/9f70a352f9f8630ab3aa0d06af5cb9532bd8c21d.tar.gz",
    "openai",
    "tiktoken").apt_install("ffmpeg").run_function(download_whisper)

@stub.function(image=parent_image, gpu="any", timeout=600)
def get_transcribed_chat(file_url):
    local_path = '/whisper/episode.m4a'
    download_file(file_url, local_path)

    print("Starting Chat Transcription Function")
    print("File Path:", file_url)

    # Load the Whisper model
    import whisper

    # Load model from saved location
    print("Load the Whisper model")
    model = whisper.load_model('medium', device='cuda', download_root='/whisper/')

    # Perform the transcription
    print("Starting chat transcription")
    result = model.transcribe(local_path)

    # Return the transcribed text
    print("Chat transcription completed, returning results...")
    return {'text': result['text']}

@stub.local_entrypoint()
def main(file_url):
    output = get_transcribed_chat.call(file_url=file_url)
    print(output['text'])
