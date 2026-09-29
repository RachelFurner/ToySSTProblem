FROM python:3.11.10-slim

RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    g++ \
    libgeos-dev \
    libproj-dev \
    proj-bin \
    proj-data \
    && rm -rf /var/lib/apt/lists/*

# Create the LocalDir layout
RUN mkdir -p /LocalDir/ToySSTProblem

WORKDIR /LocalDir/ToySSTProblem

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# torch_scatter/torch_sparse wheels are built per torch variant (+cu124 vs +cpu).
# Detect the variant actually installed above so this works on both GPU and
# CPU-only machines, rather than hard-coding one.
RUN TORCH_VARIANT=$(python -c "import torch; print(torch.__version__.split('+')[-1])") && \
    pip install --no-cache-dir torch_scatter torch_sparse \
        -f "https://data.pyg.org/whl/torch-2.6.0+${TORCH_VARIANT}.html"

# Download dataset into /LocalDir/ToySSTDataset.zarr
COPY download_dataset.py .
RUN python download_dataset.py

COPY . .

# Authentication is handled by the EDITO platform proxy, so JupyterLab's own
# token/password is disabled to avoid users needing to retrieve a token from logs.
CMD ["python", "-m", "jupyterlab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--ServerApp.token=", "--ServerApp.password=", "--notebook-dir=/LocalDir"]

