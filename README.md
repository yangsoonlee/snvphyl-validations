SNVPhyl Validations
===================

This repository contains the code and describes the steps followed for the three validations of the [SNVPhyl](http://snvphyl.readthedocs.io) pipeline as described in:

Aaron Petkau, Philip Mabon, Cameron Sieffert, Natalie Knox, Jennifer Cabral, Mariam Iskander, Mark Iskander, Kelly Weedmark, Rahat Zaheer, Lee S. Katz, Celine Nadon, Aleisha Reimer, Eduardo Taboada, Robert G. Beiko, William Hsiao, Fiona Brinkman, Morag Graham, The IRIDA Consortium, Gary Van Domselaar. 2016. [SNVPhyl: A Single Nucleotide Variant Phylogenomics pipeline for microbial genomic epidemiology](http://biorxiv.org/content/early/2016/12/10/092940). bioRxiv doi: http://dx.doi.org/10.1101/092940.

These consist of:

1. [Simulated data](README-simulations.md): Validation of SNVPhyl against simulated data.
2. [SNV density filtering](snv-density-filtering/README.md): Evaluation of SNVPhyl's SNV density filtering against the [Gubbins](https://github.com/sanger-pathogens/gubbins) software.
3. [Parameter optimization](salmonella_heidelberg/README.md): Evaluation and optimization of SNVPhyl's parameters against a real-world dataset.


Most of these instructions made use of the [SNVPhyl command-line interface](https://github.com/phac-nml/snvphyl-galaxy-cli) and assume that `snvphyl.py` is on the `PATH`.
