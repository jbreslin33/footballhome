# Use a pre-built image with development tools
FROM gcc:12

# Install PostgreSQL client library
RUN apt-get update && apt-get install -y \
    libpqxx-dev \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Copy source code
WORKDIR /app
COPY main.cpp .

# Compile the server
RUN g++ -std=c++17 -pthread main.cpp -lpqxx -lpq -o server

# Expose port
EXPOSE 3001

# Run the server
CMD ["./server"]