allResultsDir=/eupath/data/EuPathDB/workflows/MicrobiomeDB/5/data/all_results
sampleDetailsDir=$PROJECT_HOME/ApiCommonMetadataRepository/ISA/metadata/MBSTDY0020

ls $allResultsDir/*eukdetect* | xargs -n1 basename | perl -pe 's/.eukdetect.lineage_abundance.tsv//' | while read -r study; do

sampleDetailsPath=$sampleDetailsDir/$study.txt

perl -i -pe 's{^name}{000name}' $sampleDetailsPath


sort -t $'\t' -k1,1 $sampleDetailsPath -o $sampleDetailsPath


perl -i -pe 's{^000name}{name}' $sampleDetailsPath

done
