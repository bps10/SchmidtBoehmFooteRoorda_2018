# Schmidt, Boehm, Foote, Roorda (2018). 

These scripts were developed for the analysis of hue scaling experiments performed with an adaptive optics microstimulator. The results of this work are described in the publication titled, [The spectral identity of foveal cones is preserved in hue perception](https://www.biorxiv.org/content/early/2018/05/09/317750).

## Installation

The code in this repository is dependent upon [AOVIS_toolbox](https://github.com/RoordaLab/AOVIS_toolbox). 

First install the toolbox:

1. Clone the repository: `git cone https://github.com/RoordaLab/AOVIS_toolbox`.

2. Open MATLAB as an administrator.

3. Change directory into AOVIS_toolbox: `cd AOVIS_toolbox`

4. Run `install.m`. This will add AOVIS_toolbox and two dependencies onto your MATLAB path. 

Then download this repository. From the command line:

`git clone https://github.com/bps10/SchmidtBoehmFooteRoorda_2018/`

## Usage

Analyses can be run one at a time or all together by running `main.m`. 

## Organization

The `dat` directory contains all of the raw data needed to generate each plot.

M-files that begin with `get_`, `compute_`, `add_` and `load_` are helper functions that are called by the plotting routines.

M-files that begin with `plot_` will generate plots and print the results of analyses to the MATLAB terminal. If save_plots flag is true, plots will be saved in the `img` directory, which will be automatically created if it does not exist. `main.m` will additionally save the results of statistical tests in a text file organized in a `stats` directory.



