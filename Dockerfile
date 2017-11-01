FROM python:3.6-alpine

RUN apk add --update --no-cache \
    build-base \
    ca-certificates \
		g++ \
    git \
    libffi \
    libffi-dev \
    libpq \
    libxml2-dev \
    libxslt-dev \
    nodejs \
    python3-dev \
    wget
RUN update-ca-certificates

WORKDIR /app

# Add requirements files before to avoid rebuilding dependencies
# every time any file is modified.
ADD package.json .
ADD npm-shrinkwrap.json .
RUN npm install

ADD eu-structural-funds/requirements.txt eu-structural-funds/requirements.txt
RUN pip3 install -r eu-structural-funds/requirements.txt

ADD requirements.txt .
RUN pip3 install -r requirements.txt

ADD . .

ENV PATH "$PATH:/app/node_modules/.bin"
ENV DPP_REDIS_HOST="redis"
ENV CELERY_BROKER="amqp://guest:guest@mq:5672//"
ENV CELERY_BACKEND="amqp://guest:guest@mq:5672//"
ENV GIT_REPO=https://github.com/openspending/os-data-importers.git

EXPOSE 5000

CMD /app/docker/startup.sh
