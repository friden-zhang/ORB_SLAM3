# Ubuntu 22.04 EuRoC / TUM-VI Reproduction Notes

This note records the local setup validated for running ORB-SLAM3 on Ubuntu 22.04 with EuRoC and TUM-VI in monocular and monocular-inertial modes.

## Build setup

Pangolin is pinned as a git submodule:

```bash
git submodule update --init --recursive Thirdparty/Pangolin
git -C Thirdparty/Pangolin describe --tags --exact-match
```

The expected tag is `v0.6`. The top-level build script builds the bundled `Components/DBoW2`, `Components/g2o`, and `Components/Sophus` code, installs Pangolin locally to `Thirdparty/Pangolin-install`, extracts `Vocabulary/ORBvoc.txt`, and configures ORB-SLAM3 with that local Pangolin package:

```bash
./build.sh
```

The Ubuntu 22.04 adaptation keeps SLAM example logic unchanged. The build flags no longer use `-march=native`, which avoided runtime heap corruption on the tested Ubuntu 22.04 / WSL2 machine. `System::Shutdown()` waits for worker and viewer threads to finish before trajectory saving, which avoided a shutdown crash after EuRoC monocular-inertial runs.

## Dataset layout

Datasets are kept inside the repository but ignored by git:

```text
Datasets/EuRoC/MH_01_easy
Datasets/TUM-VI/dataset-room1_512_16
```

The validation used EuRoC ASL format and the TUM-VI exported EuRoC-style `512_16` sequence. Equivalent extracted copies or symlinks at the same paths work.

## Run commands

EuRoC monocular:

```bash
./Examples/Monocular/mono_euroc \
  Vocabulary/ORBvoc.txt \
  Examples/Monocular/EuRoC.yaml \
  Datasets/EuRoC/MH_01_easy \
  Examples/Monocular/EuRoC_TimeStamps/MH01.txt \
  euroc_mono_MH01_full
```

EuRoC monocular-inertial:

```bash
./Examples/Monocular-Inertial/mono_inertial_euroc \
  Vocabulary/ORBvoc.txt \
  Examples/Monocular-Inertial/EuRoC.yaml \
  Datasets/EuRoC/MH_01_easy \
  Examples/Monocular-Inertial/EuRoC_TimeStamps/MH01.txt \
  euroc_mono_imu_MH01_full
```

TUM-VI monocular:

```bash
./Examples/Monocular/mono_tum_vi \
  Vocabulary/ORBvoc.txt \
  Examples/Monocular/TUM-VI.yaml \
  Datasets/TUM-VI/dataset-room1_512_16/mav0/cam0/data \
  Examples/Monocular/TUM_TimeStamps/dataset-room1_512.txt \
  tumvi_mono_room1_full
```

TUM-VI monocular-inertial:

```bash
./Examples/Monocular-Inertial/mono_inertial_tum_vi \
  Vocabulary/ORBvoc.txt \
  Examples/Monocular-Inertial/TUM-VI.yaml \
  Datasets/TUM-VI/dataset-room1_512_16/mav0/cam0/data \
  Examples/Monocular-Inertial/TUM_TimeStamps/dataset-room1_512.txt \
  Examples/Monocular-Inertial/TUM_IMU/dataset-room1_512.txt \
  tumvi_mono_imu_room1_full
```

Pure monocular EuRoC and TUM-VI examples keep their original viewer flag disabled. Monocular-inertial examples open the viewer.

## Validation summary

All four commands completed with exit code `0` in the validated checkout:

| Run | Frame trajectory | Keyframe trajectory |
| --- | ---: | ---: |
| EuRoC monocular | `3679` lines | `320` lines |
| EuRoC monocular-inertial | `2734` lines | `287` lines |
| TUM-VI monocular | `2720` lines | `110` lines |
| TUM-VI monocular-inertial | `2704` lines | `110` lines |

Generated trajectory files are named `f_*.txt` and `kf_*.txt`; they are ignored by git.
