FROM python:3.13-alpine
WORKDIR /app
COPY --chmod=644 server.py .
USER 65534:65534
EXPOSE 5000
CMD ["python", "-u", "server.py"]
