# Production Stage
FROM nginx:stable-alpine AS production
WORKDIR /usr/share/nginx/html

# Copy prebuilt React app from the local machine
COPY build/ .

# Expose the default Nginx HTTP port
EXPOSE 80

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]