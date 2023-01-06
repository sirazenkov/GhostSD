set sig_list [list clk rst start idata_sd\[3:0\] odata_sd\[3:0\] addr\[9:0\] wdata\[3:0\] write_en rdata\[3:0\] crc_fail done i]
gtkwave::addSignalsFromList $sig_list
gtkwave::highlightSignalsFromList "top.d_driver_tb.idata_sd\[3:0\]"
gtkwave::highlightSignalsFromList "top.d_driver_tb.odata_sd\[3:0\]"
gtkwave::highlightSignalsFromList "top.d_driver_tb.addr\[9:0\]"
gtkwave::highlightSignalsFromList "top.d_driver_tb.wdata\[3:0\]"
gtkwave::highlightSignalsFromList "top.d_driver_tb.rdata\[3:0\]"
gtkwave::/Edit/Data_Format/Binary
