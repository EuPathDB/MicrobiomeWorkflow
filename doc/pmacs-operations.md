# PMACS operations

![pic](https://static.wikia.nocookie.net/looneytunes/images/8/82/Mama%26Beaky.png/revision/latest/scale-to-width-down/353?cb=20100329104318)

PMACS workflow dir is here: /project/eupathdblab/workflows/MicrobiomeDB/5/data

You can have the live site workflow prepare analysis jobs and monitor the running jobs, or you can set things up by yourself and copy the files to the correct destinations. Wojtek would normally start off with the workflow, and then take over after any failures.

## DJob operations
The live site workflow should take care of running DJob, and if it fails and you need to rerun bits of it, you need to improvise the commands because Wojtek didn't write them down.

For an overall guide to 16s see [this doc](16s-guide.md).

## Nextflow workflows

This is how you start Nextflow after you prepare an appropriate `./nextflow.config`, or restart after a failure:

humann
```
bsub -e bsub.e -o bsub.o 'nextflow run VEuPathDB/humann-nextflow -with-trace -c ./nextflow.config -resume | tee tee.out '
```

CORRAL
```
bsub -e bsub.e -o bsub.o 'nextflow run wbazant/CORRAL -r main -c ./nextflow.config -with-trace -resume | tee tee.out'
```

I then do `tail -f tee.out` to follow progress.

## cleaning up once the study completes
Metagenomics fastqs are big, and we get charged for storage. On the other hand, keeping individual task logs can be good. So delete everything that's bigger than twenty megabytes:
```
find work -type f -size +20M -delete
```

Additionally, Wojtek got rid of all the .fastq files when he was leaving so the project doesn't get charged for storage.

He used this command:
```
cd /project/eupathdblab/workflows/MicrobiomeDB/5/data
find otuDADA2_* -type f -size +20M -delete
```


