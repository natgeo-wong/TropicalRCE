using DrWatson
@quickactivate "TropicalRCE"

include(srcdir("reanalysis.jl"))
include(srcdir("diurnal.jl"))

compilesavesfc.([
    "ssr","str","sshf","slhf","tsr","ttr",
    "hcc","mcc","lcc","tcc","sst","t2m",
    "tcw","tcwv","lsm"
])

compilesavepre.(["w_air","z_air","t_air"])

compilesaveprehour("cc_air",levels=[
    10,20,30,50,70,100,125,150,175,200,225,
    250,300,350,400,450,500,550,600,650,700,750,
    775,800,825,850,875,900,925,950,975,1000
]); compileresavediurnalpre("cc_air")

compilesavesfcfeb.([
    "ssr","str","sshf","slhf"
])
