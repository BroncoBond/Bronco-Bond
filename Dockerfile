# Use an official Node.js runtime as a base image
FROM node:21-slim

# Set the working directory in the container to 
WORKDIR /usr/src/app

# Install app dependencies
COPY package*.json ./

RUN npm install

# Bundle app source
COPY . .

# Make port 8080 available to the world outside this container
EXPOSE 8080

CMD [ "npm", "start" ]