FROM python:3.8-slim
LABEL maintainer Cquinta <cquinta@gmail.com.
LABEL description "Dockerfile  para exemplo do exporter do curso descomplicando prometheus"

WORKDIR /app
COPY . /app
RUN pip3 install -r requirements.txt

CMD python3 exporter.py
