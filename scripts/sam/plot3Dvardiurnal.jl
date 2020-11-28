using DrWatson
@quickactivate "TropicalRCE"

include(srcdir("plot3D.jl"))

plot3Ddiurnal("Control2DHR","DTP1M",plotWTG=false)
plot3Ddiurnal("Control2DHR","IPW1M",plotWTG=false)
plot3Ddiurnal("Control2DHR","WPW1M",plotWTG=false)
plot3Ddiurnal("Control2DHR","DRY1M",plotWTG=false)
plot3Ddiurnal("Control2DHR","DTP2M",plotWTG=false)
plot3Ddiurnal("Control2DHR","IPW2M",plotWTG=false)
plot3Ddiurnal("Control2DHR","WPW2M",plotWTG=false)
plot3Ddiurnal("Control2DHR","DRY2M",plotWTG=false)

plot3Ddiurnal("LSVert","DTP1M",plotWTG=false)
plot3Ddiurnal("LSVert","IPW1M",plotWTG=false)
plot3Ddiurnal("LSVert","WPW1M",plotWTG=false)
plot3Ddiurnal("LSVert","DRY1M",plotWTG=false)
plot3Ddiurnal("LSVert","DTP2M",plotWTG=false)
plot3Ddiurnal("LSVert","IPW2M",plotWTG=false)
plot3Ddiurnal("LSVert","WPW2M",plotWTG=false)
plot3Ddiurnal("LSVert","DRY2M",plotWTG=false)

plot3Ddiurnal("Shear","DTP1M",plotWTG=false)
plot3Ddiurnal("Shear","IPW1M",plotWTG=false)
plot3Ddiurnal("Shear","WPW1M",plotWTG=false)
plot3Ddiurnal("Shear","DRY1M",plotWTG=false)
plot3Ddiurnal("Shear","DTP2M",plotWTG=false)
plot3Ddiurnal("Shear","IPW2M",plotWTG=false)
plot3Ddiurnal("Shear","WPW2M",plotWTG=false)
plot3Ddiurnal("Shear","DRY2M",plotWTG=false)

plot3Ddiurnal("WTG","IPW1M",plotWTG=true)
plot3Ddiurnal("WTG","WPW1M",plotWTG=true)
plot3Ddiurnal("WTG","DRY1M",plotWTG=true)
plot3Ddiurnal("WTG","IPW2M",plotWTG=true)
plot3Ddiurnal("WTG","WPW2M",plotWTG=true)
plot3Ddiurnal("WTG","DRY2M",plotWTG=true)
