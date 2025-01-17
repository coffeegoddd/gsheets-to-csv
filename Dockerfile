# Container image that runs your code
FROM python:3.9.5-alpine

RUN apk add --no-cache bash curl jq git \
    && curl -L https://github.com/dolthub/dolt/releases/latest/download/install.sh | bash \
    && mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2 \
    && dolt config --global --add metrics.host eventsapi.awsdev.ld-corp.com \
    && dolt config --global --add metrics.port 443
    #&& dolt config --global --add user.email bojack@horseman.com \
    #&& dolt config --global --add user.name "Bojack Horseman" \

# Install Poetry
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | POETRY_HOME=/opt/poetry python && \
    cd /usr/local/bin && \
    ln -s /opt/poetry/bin/poetry && \
    poetry config virtualenvs.create false

COPY pyproject.toml poetry.lock* ./

RUN poetry install --no-root

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.py /usr/src/entrypoint.py

# Code file to execute when the docker container starts up (`entrypoint.sh`
ENTRYPOINT ["python", "/usr/src/entrypoint.py"]
