#!/bin/sh
# Env bridge for container use: turns S2S_* env vars into serve flags so
# secrets live in masked env entries instead of command-line arguments
# (command args are visible in `docker inspect`; env is not shown there
# with the entrypoint indirection, and Unraid masks env fields in its UI).
#
# With no env set this is transparent: the original command passes through
# untouched, so `docker run ... serve --stt whisper ...` still works raw.
set -e

if [ "${1:-}" = "serve" ] && [ -n "${S2S_LLM_BASE_URL:-}" ]; then
    set -- serve \
        --host "${S2S_HOST:-0.0.0.0}" \
        --port "${S2S_PORT:-8765}" \
        --device "${S2S_DEVICE:-cpu}" \
        --stt "${S2S_STT:-faster-whisper}" \
        --tts "${S2S_TTS:-kokoro}" \
        --llm_backend "${S2S_LLM_BACKEND:-chat-completions}" \
        --responses_api_base_url "$S2S_LLM_BASE_URL"
    [ -n "${S2S_LLM_API_KEY:-}" ] && set -- "$@" --responses_api_api_key "$S2S_LLM_API_KEY"
    [ -n "${S2S_LLM_MODEL:-}" ]   && set -- "$@" --model_name "$S2S_LLM_MODEL"
fi

exec speech-to-speech "$@"
