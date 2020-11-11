using DrWatson
@quickactivate "TropicalRCE"

include(srcdir("SAM.jl"))

createsnd("DTP1M",exp="Control2DHR",config="DTP1M")
createsnd("DTP2M",exp="Control2DHR",config="DTP2M")
createsnd("IPW1M",exp="Control2DHR",config="IPW1M")
createsnd("IPW2M",exp="Control2DHR",config="IPW2M")
createsnd("WPW1M",exp="Control2DHR",config="WPW1M")
createsnd("WPW2M",exp="Control2DHR",config="WPW2M")
createsnd("DRY1M",exp="Control2DHR",config="DRY1M")
createsnd("DRY2M",exp="Control2DHR",config="DRY2M")
