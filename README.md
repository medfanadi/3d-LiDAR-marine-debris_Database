# 3D-LiDAR-Marine-Debris: Detection and Tracking Dataset

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![MATLAB](https://img.shields.io/badge/MATLAB-Required-orange.svg)](https://www.mathworks.com/products/matlab.html)
[![Ouster](https://img.shields.io/badge/Sensor-Ouster_OS1--128-lightgrey.svg)](https://ouster.com/)
[![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)](https://www.python.org/downloads/)

This repository hosts a comprehensive multi-acquisition 3D-LiDAR dataset specifically curated to advance research in detecting and tracking floating marine debris. The data was captured utilizing a high-resolution **Ouster OS1-128** sensor across both controlled laboratory flume tank at IFREMER and dynamic real-world maritime environments.

---

## 🔬 Experimental Frameworks

### 1. Controlled Flume Tank Experiments (IFREMER, Boulogne-sur-Mer)
Advanced maritime experiments were conducted in the specialized wave-and-current flume tank at the IFREMER facility in Boulogne-sur-Mer, France.

* **Objective:**  Evaluate the performance of a multi-sensor 3D LiDAR system integrated with an onboard IMU for detecting, isolating, and estimating the spatial extent of floating debris under varying wave and current conditions. The experiments also aimed to validate the tracking filter using the collected 3D LiDAR measurements.

<p align="center">
  <img width="100%" alt="IFREMER Flume Tank Experimental Setup and Data Output" src="https://github.com/user-attachments/assets/3c72166f-0560-4f2a-b4b6-8b36da7b59d0" />
</p>
<p align="center">
  <em>Experiments at IFREMER to evaluate the 3D LiDAR sensor feasibility for marine debris detection.</em>
</p>

### 2. Real-World Port Testing (Calais Port)
Detecting floating plastic debris in-situ presents severe operational challenges for 3D-LiDAR sensors, primarily due to low water-surface retroreflectivity, highly dynamic environmental clutter, and water surface refraction.

* **Objective:**  Evaluate the algorithm’s performance in extracting, clustering, and tracking uncertain point-cloud geometries associated with small, unactuated floating objects under realistic wave and current conditions.
In-situ detection of floating plastic debris using 3D LiDAR sensors remains challenging due to the low reflectivity of the water surface and the presence of substantial environmental clutter.

<p align="center">
  <img width="100%" alt="Calais Port Experimental Setup and Data Output" src="https://github.com/user-attachments/assets/0b3c20ed-7e5f-44b4-b069-2febec6aea0b" />
</p>
<p align="center">
  <em>Detection of marine debris using 3D LiDAR data.</em>
</p>

#### Experimental Tracking 

An advanced spatial filtering using **Joint Probabilistic Data Association Filter (JPDAF)** 


<p align="center">
  <img width="909" height="418" alt="3D-LiDAR Multi-Object Tracking Visualization" src="https://github.com/user-attachments/assets/3bb3dbf4-ed26-4ed6-ae42-60a6ce4f3f56" />
</p>
<p align="center">
  <em>3D-LiDAR multi-object tracking trajectory and state estimation (velocity and acceleration) of floating debris targets.</em>
</p>

The tracking filter estimates the full 3D kinematic state—including position, velocity, and acceleration—for each detected floating debris item.

<p align="center">
  <img width="923" height="422" alt="Multi-Object Tracking State Estimation" src="https://github.com/user-attachments/assets/fe7bcab2-a4c7-4c8f-9d61-5ae0a718515b" />
</p>
<p align="center">
  <em>3D-LiDAR multi-object tracking: Estimated velocity, and acceleration profiles for each detected debris target.</em>
</p>
---

## 📌 Repository Overview

### Data Formats & Architecture
The dataset is split into two primary layers to facilitate both hardware-level packet decoding and high-level abstract analysis:
* **Raw Packet Captures (`.pcap`)**: raw network data packets recorded directly from the sensor streams.
* **Processed Metadata (`.json`)**: Synchronized frame metadata containing structured sensor information, telemetry, and index arrays.

### Dataset Specifications

| Metric | Specification |
| :--- | :--- |
| **Sensor Hardware** | Ouster OS1-128 Uniform Beam 3D LiDAR |
| **Temporal Frequency** | 10 Hz (1 frame every 0.1 seconds) |
| **Target Application** | Point Cloud Processing, Cluster Segmentation, LIDAR-constrained Box Particle Filtering (LC-BPF) |
| **Total Volume** | ~100 GB (Active recording campaigns ongoing) |

---

## 🛠️ Hardware Specification

All data streams were captured using an **Ouster OS1-128 with embarked IMU** digital LiDAR sensor configured with a uniform vertical angular resolution. The primary hardware parameters maintained throughout both experimental campaigns are outlined below:

| Parameter | Operational Setting | Technical Notes |
| :--- | :--- | :--- |
| **Beam Configuration** | 128 Channels (Uniform) | Provides high-density vertical sampling over water surfaces |
| **Frame Rate** | 10 Hz | Sampling period $\Delta t = 0.1$\,s between successive packets |
| **Horizontal Resolution** | 1024 columns | Balanced azimuth resolution for high-speed frame parsing |
| **Wavelength** | 865 nm | Near-infrared band optimized for surface reflectivity |
| **Range Resolution** | $\pm 1$ to $3$\,cm | Tightly bounds the structural sensor uncertainty ($[\mathbf{v}]$) |


---

## 👥 Contributors 

* **Mohamed Fnadi** – LISIC / Université du Littoral Côte d'Opale (ULCO)
* **Régis Lherbier** – LISIC / Université du Littoral Côte d'Opale (ULCO)
* **Benoît Gaurier** – IFREMER Boulogne-Sur-Mer
* **Khalil Tarhda** – Research Intern, LISIC / ULCO (2026)
* **Bastien Fabre** – Research Intern, LISIC / ULCO (2024)
