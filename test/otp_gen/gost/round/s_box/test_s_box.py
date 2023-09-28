#========================================================
#company: Tomsk State University
#developer: Simon Razenkov
#e-mail: sirazenkov@stud.tsu.ru
#description: S-box (substitution block) module testbench
#========================================================

import os
import cocotb
from cocotb.runner import get_runner
from cocotb.triggers import Timer

test_dir = os.path.dirname(__file__)
rtl_dir = os.path.abspath(os.path.join(test_dir, '..', '..', '..', '..', '..', 'src'))

@cocotb.test()
async def s_box_tb(dut):
    """S-box module testbench""" 
    iword = dut.iword
    oword = dut.oword
    dataset = ['FDB97531', '2A196F34', 'EBD9F03A', 'B039BB3D', '68695433']
    dataset = [int(d, 16) for d in dataset]

    for i in range(len(dataset)-1):
        iword.value = dataset[i]
        await Timer(1, units='ns')
        assert int(oword.value) == dataset[i+1], f"S-box operation failed on {i+1} input value: output expected - {dataset[i+1]}, calculated - {int(oword.value)}!"

def test_s_box():
    sim = os.getenv("SIM", "icarus")

    verilog_sources = [os.path.join(rtl_dir, 'otp_gen', 'gost', 'round', 's_box.v')]
    runner = get_runner(sim)
    runner.build(
            verilog_sources=verilog_sources,
            hdl_toplevel="s_box",
            always=True,
    )

    runner.test(hdl_toplevel="s_box", test_module="test_s_box",)

if __name__ == "__main__":
    test_s_box()

