# 3D-LiDAR-Marine-Debris: Detection, Classification & Tracking Dataset

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![ROS 2](https://img.shields.io/badge/ROS_2-Humble%20%2F%20Jazzy-blue.svg)](https://docs.ros.org/)
[![MATLAB](https://img.shields.io/badge/MATLAB-Required-orange.svg)](https://www.mathworks.com/products/matlab.html)
[![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)](https://www.python.org/downloads/)
[![Ouster](https://img.shields.io/badge/Sensor-Ouster_OS1--128-lightgrey.svg)](https://ouster.com/)

This repository hosts a multi-acquisition 3D-LiDAR dataset specifically curated to advance research in detecting, classifying, and tracking floating marine debris (e.g., plastics, fishing gear, organic debris). 

The dataset was collected using an **Ouster OS1-128** sensor with an onboard IMU across both controlled flume tank environments (IFREMER) and dynamic real-world maritime environments (Calais Port & Canal). It serves as a benchmark for perception algorithms (Deep Learning / Vision Transformers) and state estimation filters (LC-BPF, JPDAF, NMPC guidance).

---

## 🔬 Experimental Frameworks

### 1. Controlled Flume Tank Experiments (IFREMER, Boulogne-sur-Mer)
Controlled hydrodynamic experiments were conducted in the specialized wave-and-current flume tank at the IFREMER facility in Boulogne-sur-Mer, France.

* **Objective:** Evaluate the performance of the 3D-LiDAR perception pipeline and IMU telemetry alignment under controlled wave and current dynamics. The collected data supports spatial isolation, bounding-box uncertainty minimization, and state estimation of floating targets using advanced filtering methods (e.g., **LIDAR-Constrained Box Particle Filter - LC-BPF**).

<p align="center">
  <img width="90%" alt="IFREMER Flume Tank Setup and Point Cloud Output" src="https://github.com/user-attachments/assets/3c72166f-0560-4f2a-b4b6-8b36da7b59d0" />
</p>

### 2. In-Situ Real-World Testing (Calais Port & Canal)
Detecting and tracking small, unactuated floating plastic debris *in situ* presents severe operational challenges, including low water surface retroreflectivity, dynamic environmental clutter, and surface wave motion.

* **Objective:** Validate radial segmentation, Euclidean clustering, and multi-object tracking (MOT) performance under unconstrained environmental conditions.

<p align="center">
  <img width="90%" alt="Calais Port Experimental Setup and Data Output" src="https://github.com/user-attachments/assets/0b3c20ed-7e5f-44b4-b069-2febec6aea0b" />
</p>

#### Multi-Object Tracking & Estimation
Data association and spatial filtering under clutter are benchmarked using interval analysis, **Joint Probabilistic Data Association Filter (JPDAF)**, and **LC-BPF**.

<p align="center">
  <img src="https://github.com/user-attachments/assets/70a830c7-0e7c-4548-af64-dc179f4f781d" width="70%" alt="3D-LiDAR Multi-Object Tracking Output" />
  <br>
  <em>3D-LiDAR multi-object tracking trajectories and state estimation of floating debris targets.</em>
</p>

---

## 📌 Repository Overview

### Data Architecture
The dataset is structured into two primary layers to facilitate low-level sensor decoding as well as high-level tracking and perception research:
* **Raw Stream Captures (`.pcap`)**: High-fidelity network packet recordings direct from the sensor.
* **Processed Metadata & Point Clouds (`.json` / `.ply` / `.bag`)**: Synchronized frame metadata containing IMU telemetry, spatial coordinate transformations, and annotated point-cloud clusters.

### Dataset Specifications

| Metric | Specification |
| :--- | :--- |
| **Sensor Hardware** | Ouster OS1-128 Uniform Beam 3D LiDAR (6-DOF Onboard IMU) |
| **Temporal Frequency** | 10 Hz ($\Delta t = 0.1\text{ s}$) |
| **Primary Tasks** | 3D Point Cloud Segmentation, Deep Learning / Transformer Classification, LC-BPF Tracking, NMPC Guidance |
| **Total Volume** | ~100 GB (Active recording campaigns ongoing) |

---

## 🛠️ Hardware Specification

All data streams were captured using an **Ouster OS1-128 with embarked IMU** digital LiDAR sensor configured with a uniform vertical angular resolution.

| Parameter | Operational Setting | Technical Notes |
| :--- | :--- | :--- |
| **Beam Configuration** | 128 Channels (Uniform) | Provides high-density vertical sampling over water surfaces |
| **Frame Rate** | 10 Hz | Sampling period $\Delta t = 0.1\text{ s}$ between successive packets |
| **Horizontal Resolution** | 1024 columns | Balanced azimuth resolution for real-time processing |
| **Wavelength** | 865 nm | Near-infrared band optimized for water/target reflectivity contrast |
| **Range Resolution** | $\pm 1$ to $3\text{ cm}$ | Tightly bounds the spatial uncertainty ($[\mathbf{v}]$) for interval filters |

---

## 🏛️ Project & Institutional Context

This dataset is developed within the **TrackFloat** project framework, led by **ULCO / LISIC (Team EdyFI)** in collaboration with:
* **IFREMER Boulogne-sur-Mer** (Hydrodynamic flume tank testing)
* **University of Oldenburg, Germany** (Guaranteed NMPC control & Interval-based estimation)
* **Moulay Ismaïl University, Morocco** (CNN / Transformer-based target classification)

This work contributes directly to the research foundation for the upcoming **ANR JCJC** initiative on autonomous marine debris harvesting via Autonomous Surface Vehicles (ASVs).

---

## ⚖️ Dependencies and Licenses

* **Repository Code License:** Distributed under the permissive [MIT License](LICENSE).
* **MATLAB Processing Core:** Requires MATLAB paired with the **Lidar Toolbox** and **Automated Driving Toolbox**.
* **Python Stack:** Built on open-source libraries (`open3d`, `numpy`, `rosbags`) compliant with the [Python Software Foundation (PSF) License](https://docs.python.org/3/license.html).
* **Visualization:** Native compatibility with `OusterStudio` and `RViz2`.

---

## 👥 Contributors & Contact

* **Mohamed Fnadi** (Project Lead) – LISIC / Université du Littoral Côte d'Opale (ULCO)
* **Régis Lherbier** – LISIC / Université du Littoral Côte d'Opale (ULCO)
* **Benoît Gaurier** – IFREMER Boulogne-sur-Mer
* **Khalil Tarhda** – Research Intern, LISIC / ULCO
* **Bastien Fabre** – Research Intern, LISIC / ULCO