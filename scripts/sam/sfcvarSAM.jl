using DrWatson
@quickactivate "TropicalRCE"

include(srcdir("SAM.jl"))

sfcsummary("PREC","DTP2M","sst300d8",[
    "sst299d0","sst300d0","sst300d5",
    "sst300d8","sst301d0","sst301d5",
    "sst302d0","sst302d5","sst303d0"
])

sfcsummary("PREC","DRY2M","sst299d7",[
    "sst297d0","sst298d0","sst299d0","sst299d5",
    "sst299d7","sst300d0","sst300d5","sst301d0",
    "sst301d5","sst302d0"
])

sfcsummary("PREC","WPW2M","sst302d4",[
    "sst301d0","sst302d0","sst302d4","sst302d5","sst303d0"
])

sfcsummary("PREC","IPW2M","sst301d9",["sst301d9"])
sfcsummary("PREC","DTP1M","sst300d8",["sst300d8"])
sfcsummary("PREC","IPW1M","sst301d9",["sst301d9"])
sfcsummary("PREC","WPW1M","sst302d4",["sst302d4"])
sfcsummary("PREC","DRY1M","sst299d7",["sst299d7"])