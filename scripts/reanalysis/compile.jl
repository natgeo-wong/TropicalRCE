using DrWatson
@quickactivate "TropicalRCE"

include(srcdir("reanalysis.jl"))

compilesavesfc.([
    "ssr","str","sshf","slhf","tsr","ttr",
    "hcc","mcc","lcc","tcc","sst","t2m",
    "tcw","tcwv","lsm"
])

compilesavepre.(["w_air","z_air","t_air"])
