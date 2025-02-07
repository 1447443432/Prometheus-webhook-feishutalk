#FROM python:latest
#FROM registry.cn-shanghai.aliyuncs.com/jing-images/python:latest
FROM registry.cn-shanghai.aliyuncs.com/jing-images/python:alpine

WORKDIR /usr/src/app

COPY requirements.txt ./
RUN echo "https://mirrors.aliyun.com/alpine/v3.20/main/" > /etc/apk/repositories \
&& echo "https://mirrors.aliyun.com/alpine/v3.20/community/" >> /etc/apk/repositories \
&& apk add --update gcc build-base python3-dev libffi-dev font-noto-cjk\
&& apk cache clean \ 
&& pip install --no-cache-dir -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

COPY . .

CMD [ "python", "./Feishu_webhook.py" ]

