# Simple C++ HTTP Server
FROM ubuntu:22.04

# Install minimal dependencies
RUN apt-get update && apt-get install -y \
    g++ \
    libpqxx-dev \
    libpq-dev \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Copy source code
WORKDIR /app
COPY main.cpp .
COPY README.md .

# Compile the server
RUN g++ -std=c++17 -pthread main.cpp -lpqxx -lpq -o server

# Expose port
EXPOSE 3001

# Run the server
CMD ["./server"]