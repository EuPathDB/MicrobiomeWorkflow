allResultsDir=/eupath/data/EuPathDB/workflows/MicrobiomeDB/5/data/all_results
sampleDetailsDir=$PROJECT_HOME/ApiCommonMetadataRepository/ISA/metadata/MBSTDY0020

ls $allResultsDir/*eukdetect* | xargs -n1 basename | perl -pe 's/.eukdetect.lineage_abundance.tsv//' | while read -r study; do

sampleDetailsPath=$sampleDetailsDir/$study.txt

perl -i -pe 's{^name}{000name}' $sampleDetailsPath

cat $allResultsDir/$study.eukdetect.lineage_abundance.tsv \
 | perl -pe 's/;;*\t/\t/; s/.*;//' \
 | transpose \
 | perl -nE '
if($. ==1){
  die $_ unless /^lineage/;
  chomp;
  my ($x, @xs) = split "\t";
  say join("\t", "000name",
    ( map {"$_ detected"} @xs ),
    ( map {"Matches for $_ (CPM)"} @xs ),
  );
}else {
  chomp;
  my ($srr, @xs) = split ("\t", $_, -1);
  say join("\t", $srr,
    (map {$_ ? "Y" : "N"} @xs),
    @xs
  )
}
' \
 | join -11 -21 -a1 -t $'\t' $sampleDetailsPath - \
 > $sampleDetailsPath.1

mv -v $sampleDetailsPath.1 $sampleDetailsPath


perl -i -pe 's{^000name}{name}' $sampleDetailsPath

done
