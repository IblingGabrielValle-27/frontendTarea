# Etapa 1: Build de la app
FROM node:22-alpine AS build
WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

# Etapa 2: Servir con Nginx
FROM nginx:stable-alpine

# Copiar los archivos construidos de Vite
COPY --from=build /app/dist/ /usr/share/nginx/html/

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]