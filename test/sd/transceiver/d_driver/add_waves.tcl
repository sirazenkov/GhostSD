set sig_list [list clk rst start cmd_sd cmd_index\[5:0\] cmd_arg\[31:0\] cmd resp\[119:0\] done i]
gtkwave::addSignalsFromList $sig_list
gtkwave::highlightSignalsFromList "top.cmd_driver_tb.cmd_index\[5:0\]"
gtkwave::highlightSignalsFromList "top.cmd_driver_tb.cmd_arg\[31:0\]"
gtkwave::highlightSignalsFromList "top.cmd_driver_tb.resp\[119:0\]"
gtkwave::/Edit/Data_Format/Binary
