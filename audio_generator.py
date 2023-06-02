import argparse
import os
import sys
import torch

from InferenceInterfaces.PortaSpeechInterface import PortaSpeechInterface

parser = argparse.ArgumentParser(description='Generate audio from text')

parser.add_argument('--text', type=str, required=True, help='Text to be synthesized')
parser.add_argument('--outfile', type=str, required=True, help='Filename to save audio to')
args = parser.parse_args()

text = args.text
outfile = args.outfile
device = "cuda" if torch.cuda.is_available() else "cpu"
print(f"running on {device}")

tts = PortaSpeechInterface(device=device, tts_model_path='CrewChief_Jim')
tts.set_language('en')

tts.read_to_file(text_list=[text], file_location=outfile)
del tts

