# Use a pre-built image with development tools
FROM gcc:12

# Install required packages
RUN apt-get update && apt-get install -y \
    libpqxx-dev \
    cmake \
    pkg-config \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy source code and build files
COPY . .

# Build with CMake
RUN mkdir -p build && cd build && \
    cmake .. && \
    make -j$(nproc)

# Expose port
EXPOSE 3001

# Run the server
CMD ["./build/server"]