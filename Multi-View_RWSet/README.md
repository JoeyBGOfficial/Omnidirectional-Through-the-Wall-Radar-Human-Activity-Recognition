## 🛠️ III. How to Install

This repository is fully developed in MATLAB. No Python, CUDA, or extra external codebase is required.

### 🔧 Part 1: Prepare MATLAB Environment

Suggested environment:

> (1) MATLAB R2025b or later.<br>
> (2) Image Processing Toolbox.<br>
> (3) Deep Learning Toolbox.<br>
> (4) Parallel Computing Toolbox is optional and can be used for acceleration when available.

Download or clone the whole repository, then open MATLAB and enter the repository root folder:

```matlab
cd("Your_Path/Omnidirectional_TWR_HAR_mDOF_Open_Source");
```

### 🗂️ Part 2: Prepare Dataset Folders

The repository supports both the simulated dataset and measured real-world dataset. Please put them directly under the repository root folder with the following exact names:

```text
Omnidirectional_TWR_HAR_mDOF_Open_Source/
|-- Multi-View_RWSet/
|-- Multi-View_SimHSet/
|-- Functions/
|-- Visualization/
|-- Main_Train_Omnidirectional_TWR_HAR_mDOF.m
|-- Main_Infer_New_DTM.m
```

The measured dataset should be named `Multi-View_RWSet` and organized as:

```text
Multi-View_RWSet/
|-- Multi-View_RW_Training_and_Validation_Set/
|   |-- Bodyrotating/
|   |-- Empty/
|   |-- Falling to Walking/
|   |-- Grabbing/
|   |-- Kicking/
|   |-- Punching/
|   |-- Sitting Down/
|   |-- Sitting to Walking/
|   |-- Standing Up/
|   |-- Walking/
|   |-- Walking to Falling/
|   |-- Walking to Sitting/
|
|-- Multi-View_RW_Testing_Set/
|   |-- 30/
|   |-- 60/
|   |-- 90/
|   |-- 120/
|   |-- 150/
|   |-- 180/
|   |-- 210/
|   |-- 240/
|   |-- 270/
|   |-- 300/
|   |-- 330/
```

Each activity folder under `Multi-View_RW_Training_and_Validation_Set` should contain 0-degree DTM images named like:

```text
1.png, 2.png, ..., 300.png
```

Each angle folder under `Multi-View_RW_Testing_Set` should contain the same 12 activity folders, and each activity folder should contain testing DTM images named like:

```text
1.png, 2.png, ..., 30.png
```

The simulated dataset should be named `Multi-View_SimHSet` and organized in the same way:

```text
Multi-View_SimHSet/
|-- Multi-View_SimH_Training_and_Validation_Set/
|-- Multi-View_SimH_Testing_Set/
```
