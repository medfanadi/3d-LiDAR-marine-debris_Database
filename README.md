# 3D-LiDAR-Marine-Debris: Detection and Tracking Dataset

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![MATLAB](https://img.shields.io/badge/MATLAB-Required-orange.svg)](https://www.mathworks.com/products/matlab.html)
[![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)](https://www.python.org/downloads/)
[![Ouster](https://img.shields.io/badge/Sensor-Ouster_OS1--128-lightgrey.svg)](https://ouster.com/)

This repository hosts a multi-acquisition 3D LiDAR dataset, alongside **MATLAB** and **Python** implementations for the detection, segmentation, and tracking of floating marine debris. The data was captured using a high-resolution **Ouster OS1-128** sensor across both controlled laboratory conditions and real-world maritime environments.

---

## 📌 Repository Overview

* **Data Formats:** Raw packet captures (`.pcap`) and processed metadata (`.json`).
* **Hardware:** Ouster OS1-128 3D LiDAR.
* **Software:** MATLAB algorithms for point cloud processing, segmentation, and object clustering.

---

## ⚖️ Licensing and Software Dependencies

While the original code and datasets provided in this repository are open-source, interacting with the data and running the full pipeline requires specific software environments:

* **Project License (MIT):** The scripts, implementations, and datasets hosted directly in this repository are distributed under the [MIT License](LICENSE).
* **MATLAB & Lidar Toolbox:** Running the core processing pipeline requires a valid [MATLAB License](https://www.mathworks.com/pricing-licensing.html) along with the **Lidar Toolbox** (used for processing 3D point clouds, sensor calibration, and object tracking algorithms).
* **OusterStudio:** Visualizing and interacting with the raw `.pcap` sensor recordings may require [OusterStudio](https://ouster.com/products/software/ouster-studio), which is proprietary software subject to Ouster's End User License Agreement (EULA).
* **Python:** The Python data-handling scripts rely on the open-source [Python Software Foundation (PSF) License](https://docs.python.org/3/license.html).

---

## 🔬 Experimental Frameworks

### 1. Controlled Flume Tank Experiments (IFREMER, Boulogne-sur-Mer)
This phase involved advanced marine research conducted inside the specialized wave and current flume tank at the **IFREMER** facility in Boulogne-sur-Mer, France. 

* **Objective:** Evaluate multi-sensor LiDAR capabilities to detect, track, and characterize floating debris under highly controlled, simulated dynamic maritime conditions (waves, currents, and varying flow velocities).

<p align="center">
  <img width="650" height="600" alt="IFREMER Experimental Setup" src="https://github.com/user-attachments/assets/d8e3c91f-c46e-488b-b1b5-c9e1321f85ce" />
</p>

### 2. Real-World Port Environment Testing (Calais Port)
Detecting macro-plastic debris in situ presents severe challenges due to the low reflectivity of water surfaces and the chaotic dynamics of tidal or riverine environments. 

* **Objective:** Benchmark the sensor's capacity to successfully capture, isolate, and cluster sparse point cloud data originating from small, floating plastic objects under real-world ambient conditions.

<p align="center">
  <img width="100%" alt="Calais Port Experimental Setup and Data Output" src="https://github.com/user-attachments/assets/1a691508-be2c-4a91-aa55-f36b9cc08681" />
</p>

---

## 👥 Contributors 

* Mohamed Fnadi –  LISIC / Université du Littoral Côte d'Opale (ULCO)
* Régis Lherbier – LISIC / Université du Littoral Côte d'Opale (ULCO)
* Benoît Gaurier – IFREMER Boulogne-Sur-Mer
* Khalil Tarhda – Research Intern, LISIC / ULCO
* Bastien Fabre – Research Intern, LISIC / ULCO

---

## 📄 Citation

If you use this dataset in your research, please cite it as follows:

### BibTeX
```bibtex
@misc{fnadi2026marine,
  author       = {Fnadi, Mohamed and Lherbier, Régis and Gaurier, Benoit and Tarhda, Khalil and Fabre, Bastien,
  title        = {3D-LiDAR-Marine-Debris: Detection and Tracking Dataset},
  year         = {2026},
  publisher    = {GitHub},
  journal      = {GitHub Repository},
  howpublished = {\url{[https://github.com/medfanadi/3d-LiDAR-marine-debris_Database.git](https://github.com/medfanadi/3d-LiDAR-marine-debris_Database.git)}}
}
