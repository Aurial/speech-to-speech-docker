# speech-to-speech-docker

A CPU-friendly Docker image for [huggingface/speech-to-speech](https://github.com/huggingface/speech-to-speech) — a realtime voice-agent pipeline (faster-whisper STT → any OpenAI-compatible LLM → Kokoro TTS, served over a websocket/browser client on port 8765).

Upstream is Apache-2.0 and very active, but ships only a CUDA Dockerfile and publishes no registry image. This repository builds and publishes the same thing for CPU: same runtime steps, CPU torch wheels, extras matching the default serve profile (`faster-whisper`, `kokoro`), NLTK data baked in.

**Not affiliated with Hugging Face.** Report pipeline bugs [upstream](https://github.com/huggingface/speech-to-speech/issues); report image or Unraid-template problems in [Aurial/Unraid-Community-Apps](https://github.com/Aurial/Unraid-Community-Apps/issues).

## Images

`ghcr.io/aurial/speech-to-speech-docker:<s2s-version>.<build>` — the first part is the pinned upstream release, the second bumps only when the image itself changes. `latest` follows the newest tag. A GitHub Action checks PyPI daily, rebuilds and republishes automatically when upstream releases, and also publishes to Docker Hub (`aurial/speech-to-speech`) if the `DOCKERHUB_USERNAME`/`DOCKERHUB_TOKEN` repo secrets are set.

## Run

```
docker run -d --name speech-to-speech \
  -p 8765:8765 \
  -v /path/to/cache:/root/.cache \
  ghcr.io/aurial/speech-to-speech-docker:1.1.0.1 \
  serve --host 0.0.0.0 --port 8765 --device cpu \
    --stt faster-whisper --tts kokoro \
    --llm_backend chat-completions \
    --responses_api_base_url http://YOUR-LLM:8180/v1 \
    --responses_api_api_key "YOUR-KEY" \
    --model_name your-model-name
```

The container needs no GPU; it talks to any OpenAI-compatible LLM server over the network. `/root/.cache` holds the whisper and kokoro model downloads (a few GB) — mount a volume or it re-downloads on recreate.

## Build

```
docker build -t aurial/speech-to-speech:1.1.0.1 .
```

Or let the included GitHub Action do it: push a tag named like the image tag (`1.1.0.1`) and it builds and publishes, provided the repo has a `DOCKERHUB_USERNAME` secret and a `DOCKERHUB_TOKEN` secret (a Docker Hub access token with Read & Write scope).

## Updating

1. Check upstream releases: https://github.com/huggingface/speech-to-speech/releases
2. Bump the pin in `Dockerfile` (`speech-to-speech[...]==X.Y.Z`), bump `.N` when only the image changed.
3. Tag and push (or build/push locally).

## Licence

The Dockerfile and glue in this repository: MIT. The software it packages: Apache-2.0, Hugging Face, see [upstream LICENSE](https://github.com/huggingface/speech-to-speech/blob/main/LICENSE). The models downloaded at runtime (whisper, Kokoro voices) carry their own licences.
