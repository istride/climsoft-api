FROM python:3.9.7-slim-bullseye AS builder
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_DEFAULT_TIMEOUT=30 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1
RUN apt-get update --yes --quiet \
&& apt-get install --yes --no-install-recommends \
   libmariadb-dev gcc \
&& rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY requirements.txt .
RUN pip wheel --no-deps --wheel-dir wheels -r requirements.txt

FROM python:3.9.7-slim-bullseye AS base
ENV PYTHONFAULTHANDLER=1 \
    PYTHONHASHSEED=random \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_DEFAULT_TIMEOUT=30 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1
EXPOSE 5000
WORKDIR /app
RUN apt-get update --yes --quiet \
&& apt-get install --yes --no-install-recommends \
   mariadb-client wait-for-it \
&& rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/wheels /wheels
COPY --from=builder /app/requirements.txt .
RUN pip install "uvicorn~=0.22.0" /wheels/*
COPY --chmod=755 entrypoint.sh .
COPY locale locale
COPY setup.cfg setup.py .
RUN python setup.py compile_catalog --domain climsoft_messages --directory locale
COPY src .
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["uvicorn", "climsoft_api.main:app", "--host", "0.0.0.0", "--port", "5000"]

FROM base AS dev
COPY requirements_dev.txt .
COPY tests tests
RUN pip install -r requirements_dev.txt

