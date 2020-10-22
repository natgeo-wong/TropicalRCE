using DrWatson
@quickactivate "TropicalRCE"

include(srcdir("reanalysis.jl"))

compilesave.([
    "ssr","str","sshf","slhf","tsr","ttr",
    "hcc","mcc","lcc","tcc","sst","t2m",
    "tcw","tcwv","lsm"
])
