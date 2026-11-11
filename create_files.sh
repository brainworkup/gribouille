#!/bin/bash
# File: create_files.sh
# Description: Createsall Typst files at once

# Create main document
cat>Dotplot-03-verbal.typ<<'EOF'
# settext(font: "Cabin")
# setpage(margin:(top:2cm,bottom:2cm,left:2cm,right:2cm))
# setalign(justify:true)

#let(
file_qtbl=[
#{"Subdomain","zMean","zPct","range"}
#{"CoreLanguage",0.5,50,"Average"},
#{"ExpressiveVocabulary",0.7,58,"Average"},
#{"Naming",0.9,62,"HighAverage"},
#{"Identification",0.3,48,"Average"},
],
file_fig="dotplot_verbal.svg",
)

#domain(
title:"VerbalandLanguageFunctioningReport",
subtitle:"NeuropsychologicalAssessment",
caption:"Standardizedscoresacrossverbaldomains",
file_qtbl:file_qtbl,
file_fig:file_fig,
)
EOF

#Createhelperfunctions
cat>gribouille_helpers.typ<<'EOF'
//File:gribouille_helpers.typ
//Description:Helperfunctionsfordataprocessing

#letcalculate_range(zpct:number)={
#ifzpct>=98
"ExceptionallyHigh"
#elifzpct>=91
"AboveAverage"
#elifzpct>=75
"HighAverage"
#elifzpct>=25
"Average"
#elifzpct>=9
"LowAverage"
#elifzpct>=-1
"Low"
#else
"ExceptionallyLow"
#endif
}
EOF

#Createtestfile
cat>test_dotplot.typ<<'EOF'
//File:test_dotplot.typ
//Description:Testfileforgribouilledotplotfunction

#settext(font:"Cabin")
#setpage(margin:(top:2cm,bottom:2cm,left:2cm,right:2cm))

#let(
test_data=[
#{"Domain","zMean","zPct","range"}
#{"Attention",0.2,52,"Average"},
#{"Memory",0.5,55,"Average"},
#{"Language",0.8,58,"Average"},
],
)

#domain(
title:"CognitiveAssessmentTest",
subtitle:"Sampledataforgribouilledotplot",
caption:"Testdotplotfunctionality",
file_qtbl:test_data,
file_fig:"test_dotplot.svg",
)
EOF

echo"Filescreatedsuccessfully!"
ls-la*.typ
EOF

chmod+xcreate_files.sh
./create_files.sh
```
