# 3D-LiDAR-Marine-Debris: Detection and Tracking Dataset

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![MATLAB](https://img.shields.io/badge/MATLAB-Required-orange.svg)](https://www.mathworks.com/products/matlab.html)
[![Ouster](https://img.shields.io/badge/Sensor-Ouster_OS1--128-lightgrey.svg)](https://ouster.com/)
[![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)](https://www.python.org/downloads/)

This repository hosts a comprehensive multi-acquisition 3D LiDAR dataset alongside **MATLAB** and **Python** implementations optimized for the detection, segmentation, and state-bounding tracking of floating marine debris. The data was captured utilizing a high-resolution **Ouster OS1-128** sensor across both controlled laboratory flumes and dynamic real-world maritime environments.

---

## 📌 Repository Overview

### Data Formats & Architecture
The dataset is split into two primary layers to facilitate both hardware-level packet decoding and high-level abstract analysis:
* **Raw Packet Captures (`.pcap`)**: Unmodified raw network data packets recorded directly from the sensor streams.
* **Processed Metadata (`.json`)**: Synchronized frame metadata containing structured sensor information, telemetry, and index arrays.

### Dataset Specifications

| Metric | Specification |
| :--- | :--- |
| **Sensor Hardware** | Ouster OS1-128 Uniform Beam 3D LiDAR |
| **Temporal Frequency** | 10 Hz (1 frame every 0.1 seconds) |
| **Target Application** | Point Cloud Processing, Cluster Segmentation, LIDAR-constrained Box Particle Filtering (LC-BPF) |
| **Total Volume** | ~100 GB (Active recording campaigns ongoing) |

---

## 🛠️ Hardware Specification & Operational Profiles

All data streams were captured using an **Ouster OS1-128** digital LiDAR sensor configured with a uniform vertical angular resolution. The primary hardware parameters maintained throughout both experimental campaigns are outlined below:

| Parameter | Operational Setting | Technical Notes |
| :--- | :--- | :--- |
| **Beam Configuration** | 128 Channels (Uniform) | Provides high-density vertical sampling over water surfaces |
| **Frame Rate** | 10 Hz | Sampling period $\Delta t = 0.1$\,s between successive packets |
| **Horizontal Resolution** | 1024 columns | Balanced azimuth resolution for high-speed frame parsing |
| **Wavelength** | 865 nm | Near-infrared band optimized for surface reflectivity |
| **Range Resolution** | $\pm 1$ to $3$\,cm | Tightly bounds the structural sensor uncertainty ($[\mathbf{v}]$) |

---

## 🔬 Experimental Frameworks

### 1. Controlled Flume Tank Experiments (IFREMER, Boulogne-sur-Mer)
Advanced maritime research was conducted within the specialized wave and current flume tank at the **IFREMER** facility in Boulogne-sur-Mer, France. 

* **Objective:** Evaluate multi-sensor 3D-LiDAR tracking frameworks (such as the proposed LC-BPF algorithm) to detect, isolate, and bound floating debris under deterministic hydrodynamic forces (simulated wave spectra, uniform flows, and high tidal velocities).

<p align="center">
  <img src="https://github.com/user-attachments/assets/53ef5627-bdb9-4a0c-be0d-5c31feab50f1" width="650" alt="IFREMER Experimental Setup" />
</p>

### 2. Real-World Port Testing (Calais Port)
Detecting passive macro-plastic debris in situ presents severe operational challenges due to low water-surface retroreflectivity, environmental clutter, and chaotic tidal transitions.

* **Objective:** Benchmark the algorithm's capacity to extract, cluster, and track sparse point cloud geometries originating from small, unactuated floating objects under unconstrained ambient noise and wave perturbations.

<p align="center">
  <img width="100%" alt="Calais Port Experimental Setup and Data Output" src="https://github.com/user-attachments/assets/8fb895e1-2e76-4e31-bb8b-6be4fb409e1e" />
</p>

---

## ⚖️ Dependencies and Licenses

While the scripts and algorithmic setups provided in this repository are fully open-source, interfacing with the dataset and running the execution pipeline requires the following environmental stack:

* **Repository Code License:** Distributed under the permissive [MIT License](LICENSE).
* **MATLAB Processing Core:** Requires a valid [MATLAB License](https://www.mathworks.com/pricing-licensing.html) paired with the **Lidar Toolbox** (used for geometric 3D point cloud filtering, interval propagation, and object-tracking).
* **OusterStudio (Optional):** Used for direct local visualization and manual telemetry playback of the raw `.pcap` captures. Subject to Ouster's End-User License Agreement (EULA).
* **Python Environment:** Data parsing scripts are built on open-source libraries compliant with the [Python Software Foundation (PSF) License](https://docs.python.org/3/license.html).

---

## 👥 Contributors 

* **Mohamed Fnadi** – LISIC / Université du Littoral Côte d'Opale (ULCO)
* **Régis Lherbier** – LISIC / Université du Littoral Côte d'Opale (ULCO)
* **Benoît Gaurier** – IFREMER Boulogne-Sur-Mer
* **Khalil Tarhda** – Research Intern, LISIC / ULCO (2026)
* **Bastien Fabre** – Research Intern, LISIC / ULCO (2024)

---

## 📄 Citation

If you use this dataset or code in your academic research, please cite this work using the following format:

### BibTeX
```bibtex
@misc{fnadi2026marine,
  author       = {Fnadi, Mohamed and Lherbier, R\'{e}gis and Gaurier, Benoit and Tarhda, Khalil and Fabre, Bastien},
  title        = {{3D-LiDAR-Marine-Debris: Detection and Tracking Dataset}},
  year         = {2026},
  publisher    = {GitHub},
  journal      = {GitHub Repository},
  howpublished = {\url{[https://github.com/medfanadi/3d-LiDAR-marine-debris_Database.git](https://github.com/medfanadi/3d-LiDAR-marine-debris_Database.git)}}
}
