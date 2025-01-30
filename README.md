# FRC System Diagram Generator
Generates wiring diagrams for various FRC robot components.


## Usage
### Other teams
You will likely just want to use the diagrams in the [output](output) folder.

### Team 1661 (or other contributors)
#### Building diagrams
You can simply push your changes to GitHub and the diagrams will be built automatically.
To build the diagrams locally, you will need to install the following dependencies:
- bash ([Git Bash](https://git-scm.com/downloads/win) if on windows)
- [Python 3.10](https://www.python.org/) or later
- the [Roboto](https://fonts.google.com/specimen/Roboto) font
- [Inkscape](https://inkscape.org/)

Although they are not strictly needed, please also install `npm` and/or `svgo`
to enable SVG optimization.

Then, run the following command in a bash/Git Bash prompt in the root directory of the repository:
```bash
./build.sh
```

The build script will skip building if no code or asset changes have been made since the last build.
To force a rebuild, remove the `last_build_hash.txt` file, and run the above script or push to GitHub.


## License
Python code and scripts are by Sam Wagenaar (Griffitrons 1661) and are licensed under the MIT License.
See [LICENSE.txt](LICENSE.txt) for more information.

SVG files are by Team 3161 and are licensed under the Creative Commons Attribution 4.0 International License.