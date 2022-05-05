# Provide nginx webserver
ARG ARCH=
FROM ${ARCH}nginx:stable

# Set directory to Copy App
WORKDIR /app

# Prerequisites
RUN apt update && apt install -y curl git unzip xz-utils zip libglu1-mesa

# Download Flutter SDK
RUN git clone https://github.com/flutter/flutter.git
ENV PATH "$PATH:/app/flutter/bin"
   
# Run basic check to download Dark SDK
# RUN rm -r /app/flutter/bin/cache
RUN flutter doctor

# Copy Flutter App into Image
COPY . .

# Copy nginx config
COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf
RUN chmod +x /app/entrypoint.sh

# Open http port
EXPOSE 80

# Set custom entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]



# FROM httpd

# WORKDIR /usr/local/apache2/htdocs/  

# COPY ./build/web ./

# EXPOSE 80

