[![Python 3.12](https://img.shields.io/badge/python-3.12-blue)](https://www.python.org/downloads/release/python-31214/)

# Toy SST Problem

A simple toy example of training a model to predict SST at time t + 24 hours, on a global 2-degree grid, using the SST and 2m air temperature at time t.

The problem has been formulated to give a very trivial example of training a model, and running inference (making predictions), within the [Anemoi](https://anemoi.readthedocs.io/) ecosystem.

It is not expected that this model will perform well — it is just a proof of concept that can be run in minutes, and allows users to get used to training and predicting with ML models within Anemoi.

Data comes from the ECMWF operational model.

## Notebooks

| Notebook | Description |
|---|---|
| `training_ToySST.ipynb` | Walk through the training configuration, run training, and inspect metrics with MLflow. |
| `inference_ToySST.ipynb` | Load a checkpoint, run a 15-day SST forecast, and plot predictions vs. truth. |

## Environment Setup

Both notebooks require **Python 3.12** and the packages listed in `requirements.txt`.
Curl is also required, this is pre-installed on most systems, and also installed within the Docker set up. However, if needed, it can be installed with the following:
- Ubuntu: `sudo apt install curl`
- macOS: `brew install curl`

### Recommended — virtual environment activated within notebook
The notebook has the option to pip-install the requirements file within a cell (as long as python 3.12 is being used), providing a temporary working virtual environment with everything needed to run the notebook. This is the recommended approach Alternatively, you can set up a working environment with one of the below options.

### Alternative option 1 — pip (virtual environment)

```bash
python3.12 -m venv toysst
source toysst/bin/activate
pip install --no-cache-dir -r requirements.txt
```

### Alternative option 2 — conda

```bash
conda create -n toysst python=3.12 -y
conda activate toysst
pip install --no-cache-dir -r requirements.txt
```

### Alternative option 3 — Docker

```bash
docker build -t toysst .
docker run --gpus all -p 8888:8888 toysst
```

> **Note:** JupyterLab token/password authentication is disabled in the container — access is controlled by the EDITO platform proxy. If you expose this container outside of EDITO or another authenticated proxy, you may want to re-enable authentication by removing `--ServerApp.token=` and `--ServerApp.password=` from the `CMD` in the Dockerfile.

### HPC notes (ECMWF Atos, EWC, EDITO)

#### Local compute
The code should run on most local compute. It requires around 9GB memory, and will run on both CPU and GPU, but will be very slow on CPU. Ensure to create a suitable environment using either the options within the notebook (setting `do_install = True`), or using one of the methods defined above. 

#### ECMWF ATOS
On ECMWF HPC systems the default `$TMPDIR` quota can be too small for large wheels. Override it when installing:

```bash
TMPDIR=/tmp pip install --no-cache-dir -r requirements.txt
```

If your `$HOME` quota is tight, install into `$PERM` instead:

```bash
pip install --no-cache-dir --prefix=$PERM/pip_packages -r requirements.txt
export PYTHONPATH=$PERM/pip_packages/lib/python3.11/site-packages:$PYTHONPATH
export PATH=$PERM/pip_packages/bin:$PATH
```

#### EDITO

On EDITO search the service catalogue for `Toy-sst-ml-example-gpu` or `Toy-sst-ml-example-cpu`. The GPU version of the code will run much faster, though is only usable if you have access to GPU resource. Click on 'Launch' to begin the service. The working environment will be automatically set up within these services, and the data already available. Navigate into ToySSTProblem, and open the notebooks (`training_ToySST.ipynb` and then `inference_ToySST.ipynb`) to work through the examples.

#### EWC 

If running on the European Weather Cloud (usually as part of an ECMWF organised training course), the enviroment and data will already be in place. Navigate into ToySSTProblem, and open the notebooks (`training_ToySST.ipynb` and then `inference_ToySST.ipynb`) to work through the examples.

## Quick Start

If running on an interactive server with only notebook access, clone the repository with:

```
!git clone https://github.com/RachelFurner/ToySSTProblem.git
```

Both notebooks include cells that download the required data (a zarr dataset and pre-trained model outputs) from S3 cloud storage. Set `need_data = True` in the first data cell to pull them automatically.

## Repository Structure

```
├── training_ToySST.ipynb     # Training notebook
├── inference_ToySST.ipynb    # Inference notebook
├── training_configs/         # Hydra / OmegaConf YAML configs
│   ├── ToySST.yaml           #   Main config (entry point)
│   ├── data/                 #   Data format & preprocessing
│   ├── dataloader/           #   Batch size, splits, etc.
│   ├── diagnostics/          #   Logging, plots, evaluation
│   ├── graph/                #   Graph construction options
│   ├── model/                #   Architecture definitions
│   ├── system/               #   Hardware & I/O paths
│   ├── task/                 #   Problem being addressed (forecasting, downscaling etc)
│   └── training/             #   LR schedule, loss, scalers
├── inference_ToySST.yaml     # Inference run config
├── download_dataset.py       # Downloads dataset & pretrained outputs (used by Dockerfile build)
├── requirements.txt          # Python dependencies
└── Dockerfile                # Container build file
```

## Key Dependencies

| Package | Version | Purpose |
|---|---|---|
| `anemoi-training` | 0.17.0 | Model training pipeline |
| `anemoi-inference` | 0.11.1 | Checkpoint loading & forecasting |
| `anemoi-models` | 0.19.0 | Graph-transformer architecture |
| `anemoi-graphs` | 0.9.7 | Graph construction utilities |
| `anemoi-datasets` | 0.5.40 | Zarr dataset access |
| `torch` | 2.9.0 (CUDA 12.4) | Deep learning framework |

## License

See [LICENSE](LICENSE) for details.
