FROM python:3.10

ARG ENVIRONMENT

ENV ENVIRONMENT=${ENVIRONMENT} \
    PYTHONFAULTHANDLER=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONHASHSEED=random \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    POETRY_VERSION=1.1.8 \
    PYTHONPATH=/opt/app

RUN apt install -y libpq-dev &&\
    pip install "poetry==${POETRY_VERSION}"

WORKDIR /opt/app

COPY poetry.lock /opt/app/

COPY pyproject.toml /opt/app/

COPY ./deployments/entrypoints/fapi-init.sh /usr/local/bin/fapi-init.sh

RUN poetry config virtualenvs.create false &&\
    poetry config experimental.new-installer false &&\
    poetry install $(test ${ENVIRONMENT} = "production" && echo "--no-dev") --no-interaction --no-ansi

COPY . .

EXPOSE 8000

ENTRYPOINT [ "fapi-init.sh" ]