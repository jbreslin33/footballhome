# Use a pre-built image with development tools
FROM docker.io/library/gcc:12

# Install required packages
RUN apt-get -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false update && apt-get -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false install -y \
    libpqxx-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    cmake \
    pkg-config \
    wget \
    postgresql-client \
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

# Copy wait-for-db script
COPY wait-for-db.sh /wait-for-db.sh
RUN chmod +x /wait-for-db.sh

# Run the server with wait-for-db wrapper
CMD ["/wait-for-db.sh", "db", "5432", "footballhome_user", "footballhome", "./build/server"]