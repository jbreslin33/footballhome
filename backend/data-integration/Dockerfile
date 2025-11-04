FROM node:18-alpine

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
COPY package*.json ./
RUN npm ci --only=production

# Create logs directory
RUN mkdir logs

# Bundle app source
COPY . .

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodeuser -u 1001

# Change ownership of the app directory
RUN chown -R nodeuser:nodejs /usr/src/app
USER nodeuser

# Expose port
EXPOSE 3002

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD node -e "const http=require('http'); const req=http.request({hostname:'localhost',port:3002,path:'/health',method:'GET'},(res)=>{process.exit(res.statusCode===200?0:1);}); req.on('error',()=>process.exit(1)); req.end();"

CMD ["npm", "start"]