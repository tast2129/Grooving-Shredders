# This is the git for The Grooving Shredders 23-24 Capstone Team

![Logo](https://github.com/tast2129/Grooving-Shredders/blob/main/Images/Grooving%20Shredders%20Final%20Logo.png)

Project Sponsor: Augustus Aerospace

Git contact: Wes McEvoy @ westonmcevoy@gmail.com

# Table of Contents

* For patch antenna design of phased array see files in "AnsysHFSS"
* For HackRF and Pluto transmitter code see files in "GNU Radio"
* For delay and sum beamforming algorithm see:
  * "Python": "delay_and_sum_synthesis.ipynb"
* For beamforming IP block (in construction, low-level implementation of delay and sum algorithm) see files in "HDL"
* For RFSoC PYNQ layer code see "PYNQ"
* For motor code and hardware setup image, see "Arduino"
* For PCB files for AFE and patch antennas see "Gerber Files"
* For other project documentation, see "Documentation"

# Project Background

For 8 months, our team worked to build a digital beamformer in the FPGA fabric of the RFSoC 4x2 by AMD Xilinx. Although we ran out of time to fully debug the hardware configuration we developed, we learned a lot about the board, RF, and DSP and generated some pretty cool results along the way. All radiation patterns seen on this git were generated with the help of our custom test system.

System Flowchart:
![Flowchart](https://github.com/tast2129/Grooving-Shredders/blob/main/Images/Flowchart.png)

# Custom Components

Phased Array:
![Phased_Array](https://github.com/tast2129/Grooving-Shredders/blob/main/Images/Phased_Array.png)

Turntable Test System:

![Test_System](https://github.com/tast2129/Grooving-Shredders/blob/main/Images/Test_System.jpg)

Analog Front End Board:

![AFE_PCB](https://github.com/tast2129/Grooving-Shredders/blob/main/Images/AFE_PCB.jpg)


# Results

The environment we generated the following results in:
![Setup](https://github.com/tast2129/Grooving-Shredders/blob/main/Images/Test_Setup2.jpeg)

Radiation Pattern for COTS Dipole Antenna:
![Dipole_Pattern](https://github.com/tast2129/Grooving-Shredders/blob/main/Images/Dipole_Pattern.png)

Radiation Pattern for Custom Patch Antenna:
![Patch_Pattern](https://github.com/tast2129/Grooving-Shredders/blob/main/Images/Patch_Pattern.png)

Normalized Radiation Pattern for Phased Array performing Analog Beamforming:
![Array_Pattern](https://github.com/tast2129/Grooving-Shredders/blob/main/Images/Broadside_Pattern.png)

The best looking radiation pattern we generated:
![Pristine_Pattern](https://github.com/tast2129/Grooving-Shredders/blob/main/Images/Phased_Array_Pattern.png)


# Delay and sum algorithm synthesized by "delay_and_sum_synthesis.ipynb" in "Python"

Whenever a transmitter is located at some angle off of a phased array's broadside, each element receives the same signal with a different phase shift:

![beamforming1](https://github.com/tast2129/Grooving-Shredders/assets/97580315/e911917c-0b33-4844-adb9-a0ce4064d12e)

If we try to sum the signal received by the 4 elements, we get a lot of nonsense:

![beamforming2](https://github.com/tast2129/Grooving-Shredders/assets/97580315/507baff8-44bc-445b-9302-e12a531ed3d8)

Instead, let's undo the phase shifts by multiplying each element's data by beamforming weights calculated using simple trig and the known angle of the transmitter off of the array's broadside and the spacing of the elements in the array:

![beamforming3](https://github.com/tast2129/Grooving-Shredders/assets/97580315/f1506090-c677-4844-88a7-71d21600565d)

Now when we sum the signal received by the 4 elements, not only have we received the original transmitted signal, but with around 4x the amplitude!

![beamforming4](https://github.com/tast2129/Grooving-Shredders/assets/97580315/fbafaabb-2a26-4d0b-9db6-097383a0870f)

For this reason, it's incredibly important to ensure any phase shifts induced by hardware are corrected or compensated so as to make the beamforming as effective as possible:
![Phase](https://github.com/tast2129/Grooving-Shredders/blob/main/Images/Scope_Phase.png)

# References

https://www.rfsoc-pynq.io/

https://pynq.readthedocs.io/en/latest/

https://www.xilinx.com/products/design-tools/vitis/vitis-hls.html#resources

https://discuss.pynq.io/

https://docs.amd.com/r/en-US/ds926-zynq-ultrascale-plus-rfsoc/RF-ADC-Electrical-Characteristics

https://pysdr.org/content/doa.html





