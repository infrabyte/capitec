FROM python:latest

WORKDIR /app

COPY . /app

RUN apt-get update && apt-get install -y gcc curl vim
RUN pip install -r app/requirements.txt

ENV DB_PASSWORD=devpassword123

EXPOSE 5000

CMD ["python", "app/main.py"]
