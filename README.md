# Bachelor's Thesis (RISC-V Teaching Tool)

This repository accompanies my Bachelor's thesis (written in LaTeX) which is accessible in the _Documentation_ folder. This project aimed to augment and update the existing course content for 4th-year Electronic Engineering students at the University of Galway on computer architecture, digital design and embedded programming. Specifically, this project is intended to replace an existing custom Complex Instruction Set Computing (CISC) architecture single-cycle computer. The RISC-V Instruction Set Architecture (ISA) was chosen as it is open source and at the time (Summer 2019) the initial specifications from the RISC-V Foundation were being ratified. This project was built on an existing education framework in use at the University of Galway, known as [ViciLogic](https://ieeexplore.ieee.org/document/7058191). Additionally, this project contributed to a conference publication entitled [RISC-V Online Tutor](http://dx.doi.org/10.1007/978-3-030-82529-4_14) [1].

## Project Structure

```
├── __Documentation__ => Contains documentation for this project.  
│    ├── __Diagrams__ => Diagrams created for thesis document.  
│    ├── __FYP_Thesis_Joseph_Clancy.pdf__ => Bachelor's thesis document.  
│    ├── __RISC-V Compiler Installation Guide.docx__ => Guide written to use RISC-V gcc toolchain (Winter 2019).  
│    ├── __RISC-V FYP.docx__ => Minor document with a few overview notes.  
│    ├── __RISC-V User Guide__ => Minor document meant to accompany the course content and online content on Vicilogic.  
├── __RISCV_Top/vhdl__ => Contains the VHDL source code and Xilinx Vivado project files.  
│    ├── __HDLModel__ => Contains VHDL source code for the RISC-V Device-Under-Test (DUT) and testbench.  
│    ├── __xilinxprj__ => Contains the Xilinx project files.  
├── __Scripts__ => Contains a series of convenience scripts for using the RISC-V DUT.  
│    ├── __assemble.sh__ => Runs after _compile.sh_ to assemble and link RISC-V hex output for use in the RISC-V DUT.  
│    ├── __compile.sh__ => Runs the gcc compiler on a given C file.  
│    ├── __hex_to_TB.py__ => Converts RISC-V toolchain hex output into a usable format for VHDL testbench.  
│    ├── __hex_to_viciMacro.py__ => Converts RISC-V toolchain hex output into a usable format for the ViciLogic platform.  
│    ├── __little_to_big.py__ => Converts from little to big-endian.  
```

## RISC-V Overview

RISC-V is an open-source Instruction Set Architecture (ISA) based on Reduced Instruction Set Computing (RISC) principles, offering simplicity, modularity, and extensibility. Developed at UC Berkeley in 2010, it has grown in adoption across academia and industry, supported by a strong community and overseen by RISC-V International. RISC-V's open nature allows for customization without licensing fees, making it ideal for embedded systems, IoT devices, research, and potentially high-performance computing. While its ecosystem is still maturing compared to established ISAs like ARM and x86, RISC-V's flexibility and community-driven innovation continue to drive its expansion and potential in various domains.

## Project Overview

Please refer to _"FYP_Thesis_Joseph_Clancy.pdf"_ in the _Documentation_ folder for an in-depth discussion on this project. For the sake of brevity, a brief overview is presented here.

As previously mentioned, this project was spawned from the possibility of expanding the university’s ability to educate and assess in the areas of digital system design, computer architecture, processor design
and embedded application development by taking advantage of the new open-source RISC-V ISA, and an existing learning platform in the University of Galway, ViciLogic. An overview of the project can be found in Figure 1 below. The RISC-V processor core designed during this project is a single-cycle implementation (instructions execute in one clock cycle), similar to existing processors in the university. However, the architecture being used differs from those existing in the university by following the RISC-V methodologies. RISC-V is designed to naturally complement a 5-stage architecture, though it is not mandatory.

The modularity afforded by the use of a 5-stage architecture allows each stage of the architecture can be treated separately. The implementation of these modules can be swapped by alternate user designs without much interference with other aspects of the processor core. For example, the Arithmetic Logic Unit (ALU) can be implemented in many ways, resulting in varying levels of performance when executing most if not all instructions. This modular facet allows students to explore, experiment with and analyse different implementations of the components contained within a processor.

![Figure 1 - Bachelor's Thesis Project Overview](/Documentation/Diagrams/FYP_Context.png})

## References
[1] Morgan, F. et al. (2022). RISC-V Online Tutor. In: Auer, M.E., Bhimavaram, K.R., Yue, XG. (eds) Online Engineering and Society 4.0. REV 2021. Lecture Notes in Networks and Systems, vol 298. Springer, Cham. https://doi.org/10.1007/978-3-030-82529-4_14
