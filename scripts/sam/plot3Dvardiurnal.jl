using DrWatson
@quickactivate "DiConv"

include(srcdir("plot3D.jl"))

# plot3Ddiurnal("RCEProfile","InsolRCE",plotWTG=false)
# plot3Ddiurnal("RCEProfile","InsolTRP",plotWTG=false)
#
# plot3Ddiurnal("DiurnalAmp","SlabInf")
# plot3Ddiurnal("DiurnalAmp","Slab20.0")
# plot3Ddiurnal("DiurnalAmp","Slab10.0")
# plot3Ddiurnal("DiurnalAmp","Slab05.0")
# plot3Ddiurnal("DiurnalAmp","Slab02.0")
# plot3Ddiurnal("DiurnalAmp","Slab01.0")
# plot3Ddiurnal("DiurnalAmp","Slab00.5")
# plot3Ddiurnal("DiurnalAmp","Slab00.2")
# plot3Ddiurnal("DiurnalAmp","Slab00.1")

# plot3Ddiurnal("FinalTest","control",plotWTG=false)
# plot3Ddiurnal("FinalTest","warmpool",plotWTG=false)
# plot3Ddiurnal("RCE1M","control",plotWTG=false)
# plot3Ddiurnal("RCE1M","warmpool",plotWTG=false)
# plot3Ddiurnal("RCE2M","control",plotWTG=false)
# plot3Ddiurnal("RCE2M","warmpool",plotWTG=false)

plot3Ddiurnal("Shear","DTP1M",plotWTG=false)
