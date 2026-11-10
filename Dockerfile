# CPU-friendly image for huggingface/speech-to-speech (Apache-2.0 upstream).
# Mirrors the upstream Dockerfile's runtime steps, but on a CPU base:
# the upstream image is CUDA-only and publishes no registry build.
FROM python:3.12-slim

ENV DEBIAN_FRONTEND=noninteractive PYTHONUNBUFFERED=1

# Same two system libs the upstream image installs (portaudio for audio I/O,
# sndfile for decoding); git is needed at runtime by some model loaders.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libportaudio2 libsndfile1 git \
    && rm -rf /var/lib/apt/lists/*

# Torch first, from the CPU wheel index: the default PyPI linux wheels carry
# the full CUDA stack (~6 GB). Installing the CPU wheels up-front satisfies
# the package constraint so the pip step below will not pull CUDA torch.
RUN pip install --no-cache-dir --index-url https://download.pytorch.org/whl/cpu \
        torch torchaudio

# The package itself, pinned to the upstream release this image tracks.
# Extras mirror the default serve profile: faster-whisper STT + kokoro TTS.
RUN pip install --no-cache-dir "speech-to-speech[faster-whisper,kokoro]==1.1.0"

# NLTK data the pipeline needs at runtime, baked in (upstream does the same).
RUN python -c "import nltk; nltk.download('punkt_tab'); nltk.download('averaged_perceptron_tagger_eng')"

# Model downloads (whisper, kokoro voices) land here; mount a volume to keep them.
VOLUME /root/.cache

EXPOSE 8765

ENTRYPOINT ["speech-to-speech"]
CMD ["serve", "--host", "0.0.0.0", "--port", "8765", "--device", "cpu"]
