action = "synthesis"

syn_device = "GW2A"
syn_package = "-LV18PG256C8"
syn_grade = "/I7"
syn_family = "NA"
syn_top = "ghost_sd"
syn_project = "ghost_sd"
syn_tool = "gowin"
syn_path = "/opt/soft/Gowin/Gowin_V1.9.11_linux/IDE/bin/"

modules = {
  "local" : [
    "rtl",
    "../../src",
  ],
}

files = [
  "constr/physical.cst",
  "constr/timing.sdc",
  "core/gowin_dcs/gowin_dcs.v",
  "core/gowin_rpll/gowin_rpll_otp.v",
  "core/gowin_rpll/gowin_rpll_sd.v",
]
