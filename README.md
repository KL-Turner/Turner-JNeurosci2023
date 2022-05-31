# Arousal state dependence of cortical blood volume and pupil diameter relationship

This document outlines the steps necessary to generate the figures for the manuscript **Arousal state dependence of cortical blood volume and pupil diameter relationship** by K.L. Turner, K.W. Gheres, and P.J. Drew.

---
## Generating the figures
---
The code in this repository generates all main figures, supplemental information, and statistics.

Begin by downloading the entire code repository and the data from the following locations:
* Code repository location: https://github.com/KL-Turner/Turner-Manuscript2022
* Data repository location: https://bit.ly/3wXUOSS

The OneDrive link contains several pre-analyzed structures that can be used to immediately generate the figures without re-analyzing any data. Download the entire *Pre-processed data for figures* folder (~5.0 GB) as well as this entire github code repository. Add all file contents of the pre-processed data folder file to the MATLAB file path by dragging it into the folder containing the code repository. Change to this directory in MATLAB, open the MATLAB function **MainScript_Manuscript2022.m** and run.

**Software/System Requirements:** Code was written and tested with MATLAB 2019b-2022a. Running **MainScript_eLife2020.m** took < 5 minutes to run on a 2021 Macbook Pro (edit - 2.6 Ghz 6-Core Intel i7 with 16 Gb 2400 MHz DDR4 RAM, Radeon Pro 560X GPU).

If you would like to automatically save the MATLAB figures and statistical read-outs, change line 60 of **MainScript_Manuscript2022.m** to *saveFigs = true;* This will increase the analysis time to create a new folder */Summary Figures and Structures/MATLAB Analysis Figures/*.

LabVIEW code used to acquire the data can be found at: https://github.com/DrewLab/LabVIEW-DAQ

---
## Acknowledgements
---
* multiWaitbar.m Author: Ben Tordoff https://www.mathworks.com/matlabcentral/fileexchange/26589-multiwaitbar-label-varargin
* colors.m Author: John Kitchin http://matlab.cheme.cmu.edu/cmu-matlab-package.html
* Chronux subfunctions http://chronux.org/
* Several functions utilize code written by Dr. Patrick J. Drew, Dr. Kyle W. Gheres, and Dr. Aaron T. Winder https://github.com/DrewLab

#### Contact Patrick Drew (pjd17 psu edu) or Kevin Turner (klt8 psu edu) with any questions/comments.

