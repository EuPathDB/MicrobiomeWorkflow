# PMACS setup

![pic](https://static.wikia.nocookie.net/looneytunes/images/e/e4/Granny_Vanishes.jpg/revision/latest/scale-to-width-down/300?cb=20110211214526)

## Wojtek's .bash_profile

```
# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

GUS_HOME=$HOME/gus_home

PATH=/project/eupathdblab/workflow-software/bin:$PATH
PATH=$HOME/bin:$PATH

# dada2 scripts for 16s workflow
PATH=$GUS_HOME/bin:$PATH
PATH=$HOME/lib/R-3.6.2/bin:$PATH

# Python installed - humann and stuff
PATH=$HOME/.local/bin:$PATH

# needed for humann
PATH=$HOME/.local/lib/python3.7/site-packages/humann/quantify/glpk-4.55/examples/:$PATH

# nothing for production I think
PERL5LIB=$HOME/perl5/lib/perl5:$PERL5LIB

export PATH
export PERL5LIB
export GUS_HOME

# make sure ctrl + X,ctrl +E in Bash opens a good editor
EDITOR=vi
VISUAL=$EDITOR
export EDITOR
export VISUAL

# needed for Nextflow runner
JAVA_CMD=/usr/lib/jvm/java-1.8.0/bin/java
JAVA_HOME=/usr/lib/jvm/java-1.8.0
export JAVA_CMD
export JAVA_HOME
NXF_JAVA_HOME=/bin/java
export NXF_JAVA_HOME
 
export WD=/project/eupathdblab/workflows/MicrobiomeDB/5/data
```


## 16s installation
The 16s workflow runs dada2 scripts using DJob. This requires a $GUS_HOME directory - install DJob on `yew`, and copy it over to PMACS.
It also requires R and the DADA2 package installed - Wojtek did it just for himself, try to add his stuff to path:
```
PATH=$GUS_HOME/bin:$PATH
PATH=$HOME/lib/R-3.6.2/bin:$PATH
```


## WGS installation

### WGS - `humann`
The `humann` workflow relies on custom forks of `humann` (https://github.com/wbazant/humann) and `kneaddata` (https://github.com/wbazant/kneaddata). 
Clone them locally, and install with `pip install .` .

`humann` requires a large number of tools to run. Follow https://github.com/VEuPathDB/humann-nextflow instructions, and if they don't work, fall back to original instructions.

`humann` also requires a number of databases - follow original instructions to get them. They end up in home directory:
```
~/humann_utility/
~/uniref
~/chocophlan
~/kneaddata_databases
~/metacyc-names.txt
```
The `201901` chocoplan version has been used to generate the data currently on the site, I think there have been slightly newer ones.


### WGS - `CORRAL`
Also incorrectly known as EukDetect, CORRAL was inspired by EukDetect but it stands for Clustering Of Related Read ALignments. A very good tool, so new that it's only being published now. The installation instructions are on https://github.com/wbazant/CORRAL. Feel free to open pull requests against the repository if something doesn't work.

CORRAL needs tools - `marker_alignments` from pip, `bowtie2`, and `samtools`.

You don't need to install the reference databases for CORRAL, because they are provisioned from manual delivery: we have a copy at `/eupath/data/EuPathDB/manualDelivery/MicrobiomeDB/common/EukMarkersReference/EukDetect/7/` and the workflow copies them to the cluster.
