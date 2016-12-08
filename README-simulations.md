SNVPhyl simulated data validation
=================================

This repository contains code for generating read simulations and comparing with SNVPhyl results.  Instructions to reproduce results are as follows.

```bash
sh generate-simulations.sh
sh run-simulations.sh
```

Results will appear in `simulations/e_coli_sakai_w_plasmids/`.

These simulations make use of scrips under the [scripts/](scripts/) directory, mainly:

1. [scripts/generate_variant_table.pl](scripts/generate_variant_table.pl): Generates a table of random variants.
2. [scripts/generate_genomes.pl](scripts/generate_genomes.pl): Constructs mutated reference genomes from the variant table and the genome under [references/](references/).  Simulates reads using `art_illumina`.
3. [scripts/compare_positions.pl](scripts/compare_positions.pl): Compares initially constructed variant table and table produced by SNVPhyl.  Counts TP/FP/TN/FN variants.

Dependencies
============

* [ART](http://www.niehs.nih.gov/research/resources/software/biostatistics/art/)
* Perl
* Perl modules: `cpanm Bio::SeqIO Set::Scalar`
* [SNVPhyl command-line-interface](https://github.com/phac-nml/snvphyl-galaxy-cli)
* [Docker](https://www.docker.com/)
