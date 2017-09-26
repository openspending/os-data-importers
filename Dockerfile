FROM python:3.6-alpine

RUN apk add --update git libpq nodejs
RUN apk add --update wget libffi libffi-dev ca-certificates python3-dev  \
			  g++ build-base libxml2-dev libxslt-dev 
RUN update-ca-certificates
RUN npm install -g os-types
RUN npm root -g && npm --version
RUN ls -la `npm root -g`
RUN pip3 install "os-gobble>=0.1.26" \
                 celery \
                 cchardet \
                 datapackage-pipelines \
                 datapackage-pipelines-fiscal \
                 lxml
#RUN pip3 install numpy==1.11.2 cython==0.25.1 pandas
RUN git clone http://github.com/openspending/os-data-importers.git /app
RUN cd /app && git clone http://github.com/os-data/eu-structural-funds.git
RUN mkdir /root/.gobble
RUN rm -rf /var/cache/apk/*

ENV DPP_REDIS_HOST="redis"
ENV CELERY_BROKER="amqp://guest:guest@mq:5672//"
ENV CELERY_BACKEND="amqp://guest:guest@mq:5672//"
ENV GIT_REPO=http://github.com/openspending/os-data-importers.git

EXPOSE 5000

CMD /app/docker/startup.sh
