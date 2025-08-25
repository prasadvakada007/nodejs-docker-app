# Use official Node.js image
FROM node:18

# Create app directory
WORKDIR /usr/src/app

# Copy package.json & install dependencies
COPY package*.json ./
RUN npm install

# Copy app source
COPY . .

# Expose port (same as your app)
EXPOSE 3000

# Start the app
CMD ["node", "app.js"]
