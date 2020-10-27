using DrWatson
@quickactivate "TropicalRCE"

include(srcdir("energybalance.jl"))

sebsummary(
    "DTP2M",[
        "sst299d0","sst300d0","sst300d5",
        "sst300d8","sst301d0","sst301d5",
        "sst302d0","sst302d5","sst303d0"
    ]
)

sebsummary(
    "DRY2M",[
        "sst297d0","sst298d0","sst299d0","sst299d5",
        "sst299d7","sst300d0","sst300d5","sst301d0",
        "sst301d5","sst302d0"
    ]
)

sebsummary("WPW2M",["sst301d0","sst302d0","sst302d4","sst302d5","sst303d0"])
