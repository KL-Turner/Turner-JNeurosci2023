# Relating pupil diameter and blinking to cortical activity and hemodynamics across arousal states

This document outlines the steps necessary to generate the figures for the manuscript **Relating pupil diameter and blinking to cortical activity and hemodynamics across arousal states** by K.L. Turner, K.W. Gheres, and P.J. Drew.

---
## Generating the figures
---
The code in this repository generates all main figures, supplemental information, and statistics. It contains the analysis code for all pre-processing steps as well as a demo code and examples for tracking pupil diameter.

Begin by downloading the code repository by clicking the green **Code** button at the top of the page and selecting **Download ZIP**. 
* Code repository location: https://github.com/KL-Turner/Turner-JNeurosci2022

![](https://user-images.githubusercontent.com/30758521/193090842-d33e2f7f-a12e-4cbd-9bcc-122fa59591a6.PNG)

Next, the data (~4 GB) can be downloaded from the following location: https://datadryad.org/stash/share/pv4ZmJnSk65Y6yWxoO6jdb9ou5H-x5wfOJOTCPkBntE or searched under the DOI: doi:10.5061/dryad.05qfttf5w

![](https://user-images.githubusercontent.com/30758521/193082431-7022d924-9eee-4b44-b77a-dd0204cef094.PNG)

After downloading both the code and data, unzip both folders by right clicking and selecting *Extract all*. The unzipped folders should look something like this.

![](https://user-images.githubusercontent.com/30758521/193092710-0ef277ad-885d-4585-8ae1-d2da4e0a6a1d.PNG)

The Dryad link contains several pre-analyzed structures that can be used to immediately generate the figures without re-analyzing any data. To generate the figures, begin by moving all of the files from the unzipped Dryad folder into the **Analysis Structures** folder located in the code repository.

![](https://user-images.githubusercontent.com/30758521/193088676-cca1e370-ccde-47f1-81ca-1a12a210a174.PNG)

The data should be here. 

![](https://user-images.githubusercontent.com/30758521/193093229-5e5c4e2a-0343-4e14-947b-afc60b746dcf.PNG)

The repository includes pre-analyzed structures for each analysis performed in the paper, each of these has the prefix "Results_" followed by the analysis performed. There are two images with histogram overlays that are saved to be display in figure panels. Finally, there are two examples provided (T123, T141) which includes the binary file for a demo of pupil tracking as well as the accompanying data for all other signals during that 15 minute acquisition.

From here, open MATLAB and nativate to the code's folder. Open the function **MainScript_JNeurosci2022.m**. The final view should look like this:

![](https://user-images.githubusercontent.com/30758521/193093597-927d9f57-7183-462e-acac-8115f39aaf51.PNG)

Finally, Click the green **Run** button and the figures will then take a few minutes to generate.

**Software/System Requirements:** Code was written and tested with MATLAB 2019b-2022a. Running **MainScript_JNeurosci2022.m** took < 5 minutes to run on a 2021 Macbook Pro with M1 Pro chipset and 16 Gb RAM.

If you would like to automatically save the MATLAB figures and statistical read-outs, change line 62 of **MainScript_JNeurosci2022.m** to *saveFigs = true;* This will slightly increase the analysis time and create a new folder */Summary Figures and Structures/MATLAB Analysis Figures/*. All statistical readouts and saved MATLAB figures can be found here.

LabVIEW code used to acquire the data can be found at: https://github.com/DrewLab/LabVIEW-DAQ

---
## Acknowledgements
---
* multiWaitbar.m Author: Ben Tordoff https://www.mathworks.com/matlabcentral/fileexchange/26589-multiwaitbar-label-varargin
* colors.m Author: John Kitchin http://matlab.cheme.cmu.edu/cmu-matlab-package.html
* Chronux subfunctions http://chronux.org/
* Several functions utilize code written by Dr. Patrick J. Drew, Dr. Kyle W. Gheres, and Dr. Aaron T. Winder https://github.com/DrewLab

#### Contact Patrick Drew (pjd17 psu edu) or Kevin Turner (klt8 psu edu) with any questions/comments.

