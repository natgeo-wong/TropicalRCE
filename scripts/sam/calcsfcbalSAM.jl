using DrWatson
@quickactivate "TropicalRCE"

include(srcdir("SAM.jl"))

sebsummary("Domain2D",["DTP1M","IPW1M","WPW1M","DRY1M","DTP2M","IPW2M","WPW2M","DRY2M"])
sebsummary("Domain3D",["DTP1M","IPW1M","WPW1M","DRY1M","DTP2M","IPW2M","WPW2M","DRY2M"])

sebsummary(
    "DRY2M",[
        "sst297d0","sst298d0","sst299d0","sst299d5",
        "sst299d7","sst300d0","sst300d5","sst301d0",
        "sst301d5","sst302d0"
    ]
)

sebsummary("WPW2M",["sst301d0","sst302d0","sst302d4","sst302d5","sst303d0"])
