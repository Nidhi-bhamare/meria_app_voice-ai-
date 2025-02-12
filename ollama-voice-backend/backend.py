
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from transformers import AutoModelForSeq2SeqLM
import nemo.collections.asr as nemo_asr # type: ignore
from duckduckgo_search import DDGS # type: ignore
import requests
import torchaudio # type: ignore
import torch # type: ignore
import io
import os
import uuid

app = FastAPI()

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load models
tts_model = AutoModelForSeq2SeqLM.from_pretrained("ai4bharat/indic-parler-tts-pretrained")
asr_model = nemo_asr.models.ASRModel.from_pretrained("ai4bharat/indicconformer_stt_ur_hybrid_ctc_rnnt_large")

# Configuration
OLLAMA_ENDPOINT = "http://10.10.20.90:11435/api/generate"
TEMP_DIR = "temp_audio"

os.makedirs(TEMP_DIR, exist_ok=True)

def get_current_info(query: str) -> str:
    """Fetch current information using DuckDuckGo"""
    with DDGS() as ddgs:
        results = [r for r in ddgs.text(query, max_results=3)]
    return "\n".join([f"{r['title']}: {r['body']}" for r in results])

def generate_response(user_input: str) -> str:
    """Generate response using Ollama with current context"""
    current_info = get_current_info(user_input)
    
    prompt = f"""Context: {current_info}
    Question: {user_input}
    Answer the question using the context above. Be concise and helpful."""
    
    response = requests.post(
        OLLAMA_ENDPOINT,
        json={
            "model": "llama3:latest",
            "prompt": prompt, 
            "stream": False
        }
    )
    
    return response.json().get("response", "I couldn't generate a response.")

@app.post("/asr")
async def speech_to_text(file: UploadFile = File(...)):
    """Convert speech to text"""
    try:
        file_path = f"{TEMP_DIR}/{uuid.uuid4()}.wav"
        with open(file_path, "wb") as f:
            f.write(await file.read())
        
        transcription = asr_model.transcribe([file_path])
        return {"text": transcription[0]}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/process")
async def process_query(text: str):
    """Process query and generate response"""
    try:
        response_text = generate_response(text)
        return {"response": response_text}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/tts")
async def text_to_speech(text: str):
    """Convert text to speech"""
    try:
        inputs = tts_model.prepare_inputs([text])
        outputs = tts_model.generate(inputs)
        
        # Convert output to audio bytes
        file_path = f"{TEMP_DIR}/{uuid.uuid4()}.wav"
        torchaudio.save(file_path, outputs["audio"], outputs["sampling_rate"])
        
        with open(file_path, "rb") as f:
            audio_bytes = f.read()
        
        return audio_bytes
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
