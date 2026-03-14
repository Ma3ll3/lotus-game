FROM cirrusci/flutter:stable



RUN apt-get update

RUN apt-get install -y nodejs npm



RUN npm install -g firebase-tools



WORKDIR /app



COPY . .



RUN flutter pub get