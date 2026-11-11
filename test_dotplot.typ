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
