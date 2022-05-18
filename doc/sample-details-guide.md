# Sample details guide

![pic](https://static.wikia.nocookie.net/looneytunes/images/9/9d/Beaky_Buzzard_pic_2.png/revision/latest?cb=20210611144151)

A new sample details file has its golden copy in this folder:

```
$PROJECT_HOME/ApiCommonMetadataRepository/ISA/metadata/MBSTDY0020/
```

and possibly slightly changes later for live site loading (same place, but a local branch - manually added CORRAL results for WGS studies) or EDA loading (new copy in `MBSTDY0021` folder).

## Ids should match results

Follow either:
[New study - 16s dataset](16s-guide.md)
[New study - WGS](wgs-guide.md)
and make the `name` column match.

## Some required headers
`env_feature` is required for live site.

## Headers should match ontology
Details are different for live site and EDA - see [live site sample details](live-site-sample-details.md) or [EDA sample details](eda-sample-details.md).


