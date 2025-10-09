# Team UM-Macau 2025 Software Tool

If your team competes in the [**Software & AI** village](https://villages.igem.org) or wants to
apply for the [**Best Software Tool** prize](https://competition.igem.org/judging/special-prizes), you **MUST** host all the
source code of your team's software tool in this repository, `main` branch. By the **Wiki Freeze**, a
[release](https://docs.gitlab.com/ee/user/project/releases/) will be automatically created as the judging artifact of
this software tool. You will be able to keep working on your software after the Grand Jamboree.

> If your team does not have any software tool, you can totally ignore this repository. If left unchanged, this
repository will be automatically deleted by the end of the season.

## Description
This software tool, developed by Team UM-Macau in 2025, is designed to simulate and analyze the spread of harmful factors (such as toxins or pathogens) within termite colonies using a modified SEIR - Contact Network Model and a derivative SEID - based termite infection model. It enables users to quantify, simulate, and predict the transmission process of these harmful factors among different castes of termites (workers, reproductives, young, soldiers, nymphs). By adjusting various parameters related to termite transmission, conversion, and mortality rates, as well as foraging - related settings, users can explore how these factors impact termite colony dynamics like population survival and caste - specific mortality. For more detailed background and context, you can refer to our [team wiki](link_to_team_wiki). 

Key features of this tool include:
- **Multi - caste simulation**: Simulates the spread dynamics for five termite castes with distinct parameters.
- **Parameter customization**: Allows users to adjust transmission rates, mortality rates, recovery rates, and foraging - related settings to observe different simulation outcomes.
- **Visualization of population trends**: Provides plots to display the trends of total population, alive population, and population status across different castes over time.
- **Detailed caste - level analysis**: Enables in - depth exploration of population dynamics, cumulative deaths, and related equations for each termite caste.

Compared to alternative termite infection simulation tools, our project stands out with its focus on the specific SEID model adaptation for termites, detailed parameterization based on termite biology and behavior studies, and comprehensive visualization of both overall and caste - specific dynamics.


## Installation
### Requirements
- **R Environment**: This software requires R to be installed on your system. You can download R from [CRAN](https://cran.r-project.org/).
- **Required R Packages**: The following R packages need to be installed: `shiny`, `deSolve`, `ggplot2`, `dplyr`, `scales`, `tidyr`, `bslib`, `shinydashboard`.

### Installation Steps
1. Install R from the official CRAN website if you haven't already.
2. Open R or RStudio.
3. Install the required packages by running the following commands in the R console:
   ```R
   install.packages(c("shiny", "deSolve", "ggplot2", "dplyr", "scales", "tidyr", "bslib", "shinydashboard"))

## Usage

1. **Running the Application**:
   - Save the provided R Shiny code as a `.R` file (e.g., `termite_simulator.R`).
   - Open the file in RStudio (or your preferred R environment).
   - Click the "Run App" button in RStudio, or run the following command in the R console:
     ```R
     shiny::runApp("path/to/termite_simulator.R")
2. **Using the Interface**:
   - Sidebar Settings: Adjust global settings such as worker forage interval, forage infection rate, initial infection proportions for different castes, and simulation days.
   - Tab Panels: Navigate through different tab panels (Overview, Workers, Reproductives, Young, Soldiers, Nymphs) to view population trends, dynamics, cumulative deaths, and related equations for each caste. Adjust parameters in each caste's panel to see how they affect the simulation results.
3.  **Example Usage**:
   - Default Simulation: Run the app with default parameters to see a baseline simulation of termite population dynamics over 60 days, with a forage interval of 2 days and 70% forage infection rate.
   - Adjusting Forage Interval: Change the "Forage interval (days)" slider to 1 and observe how more frequent foraging affects the spread of harmful factors.
   - Changing Mortality Rate: In the "Workers" tab, increase the "Mortality rate (γ_w)" slider to 0.5 and see the impact on worker population deaths.

### Using the Interface

- **Sidebar Settings**: Adjust global settings such as worker forage interval, forage infection rate, initial infection proportions for different castes, and simulation days.

- **Tab Panels**: Navigate through different tab panels (Overview, Workers, Reproductives, Young, Soldiers, Nymphs) to view population trends, dynamics, cumulative deaths, and related equations for each caste. Adjust parameters in each caste's panel to see how they affect the simulation results.


### Example Usage

- **Default Simulation**: Run the app with default parameters to see a baseline simulation of termite population dynamics over 60 days, with a forage interval of 2 days and 70% forage infection rate.

- **Adjusting Forage Interval**: Change the "Forage interval (days)" slider to 1 and observe how more frequent foraging affects the spread of harmful factors.

- **Changing Mortality Rate**: In the "Workers" tab, increase the "Mortality rate (y_w)" slider to 0.5 and see the impact on worker population deaths.


### Contributing

We welcome contributions to this project! If you want to contribute, please follow these steps:

1. **Fork the Repository**: Fork this repository to your own GitHub account.
2. **Clone the Fork**: Clone the forked repository to your local machine.
3. **Create a Branch**: Create a new branch for your feature or bug fix (e.g., `git checkout -b feature/new-feature` or `git checkout -b bugfix/issue-fix`).
4. **Make Changes**: Implement your changes, following the existing code style and structure.
5. **Test Your Changes**: Ensure that the application runs correctly with your changes and that any new features or fixes work as intended.
6. **Commit and Push**: Commit your changes and push them to your forked repository.
7. **Create a Pull Request**: Open a pull request from your branch to the main branch of this repository.


### Development Commands

- **Linting**: Although not strictly enforced, you can use R linting tools like `lintr` to check your code for style and potential issues. Install `lintr` with `install.packages("lintr")` and run `lintr::lint("path/to/your/code.R")`.

- **Testing**: Currently, there are no formal tests, but you should manually test the application thoroughly after making changes.


### Authors and Acknowledgment

This software tool was developed by Team UM-Macau in 2025. We would like to acknowledge the contributions of all team members who worked on the modeling, coding, and testing of this application. Special thanks to those who conducted research on termite behavior and biology, which provided the foundation for the parameters and models used in this tool.