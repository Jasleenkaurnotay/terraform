# Stage 1: Build
FROM python:3.13-slim AS builder

WORKDIR /app

COPY requirements.txt requirements.txt 

RUN --mount=type=cache,target=/root/.cache/pip \
  pip install -r requirements.txt

COPY app/ ./app/

# Stage 2: Production

FROM python:3.13-slim AS production

WORKDIR /app

RUN groupadd -r appuser && useradd -r -m appuser -g appuser

COPY data/ ./data/

COPY config.py run.py ./

COPY --from=builder /usr/local/lib/python3.13/site-packages /usr/local/lib/python3.13/site-packages

COPY --from=builder /usr/local/bin/gunicorn /usr/local/bin/gunicorn

COPY --from=builder app/app ./app/

USER appuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health')" || exit 1

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "run:app"]