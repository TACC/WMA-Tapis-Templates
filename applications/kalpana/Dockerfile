# Use Python 3.9 as base image
FROM python:3.9-slim

# Install system dependencies required for numpy, matplotlib and other packages
RUN apt-get update && apt-get install -y \
    build-essential \
    libgeos-dev \
    gdal-bin \
    libgdal-dev \
    python3-gdal \
    && rm -rf /var/lib/apt/lists/*

# Set GDAL environment variables
ENV GDAL_VERSION=3.6.2
ENV CPLUS_INCLUDE_PATH=/usr/include/gdal
ENV C_INCLUDE_PATH=/usr/include/gdal

# Set working directory
WORKDIR /app

# Install Python dependencies
RUN pip install --no-cache-dir \
    numpy \
    netCDF4 \
    matplotlib \
    shapely \
    GDAL==${GDAL_VERSION} \
    fiona \
    click \
    rich-click \
    loguru

# Copy the script
COPY kalpana.py /app/

# Make the script executable
RUN chmod +x /app/kalpana.py

# Create a directory for data
RUN mkdir /data

# Set working directory for data
WORKDIR /data

# Set the entry point
ENTRYPOINT ["python", "/app/kalpana.py"]

# Default command (can be overridden)
CMD ["--help"]