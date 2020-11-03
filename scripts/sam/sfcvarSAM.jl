using DrWatson
@quickactivate "TropicalRCE"

include(srcdir("SAM.jl"))

sfcsummary(
    "PREC","Control3D","DTP1M",
    ["DTP1M","IPW1M","WPW1M","DRY1M","DTP2M","IPW2M","WPW2M","DRY2M"]
)

sfcsummary(
    "PREC","Control2D","DTP1M",
    ["DTP1M","IPW1M","WPW1M","DRY1M","DTP2M","IPW2M","WPW2M","DRY2M"]
)

sfcsummary(
    "PREC","Control2DHR","DTP1M",
    ["DTP1M","IPW1M","WPW1M","DRY1M","DTP2M","IPW2M","WPW2M","DRY2M"]
)
