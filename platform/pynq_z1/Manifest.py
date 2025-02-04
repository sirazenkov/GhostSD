action = "synthesis"

syn_device = "xc7z"
syn_grade = "-1"
syn_package = "020clg400"
syn_top = "ghost_sd"
syn_project = "ghost_sd"
syn_tool = "vivado"

modules = {
  "local" : [
    "rtl",
    "../../src",
  ],
}

files = [
  "constr/physical.xdc",
  "constr/timing.xdc",
  "core/clk_gen/clk_gen.xci",
]
