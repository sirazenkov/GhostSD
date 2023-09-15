#========================================================
#company: Tomsk State University
#developer: Simon Razenkov
#e-mail: sirazenkov@stud.tsu.ru
#description: S-box (substitution block) module testbench
#========================================================

import os
import cocotb
from cocotb.runner import get_runner

test_dir = os.path.dirname(__file__)
rtl_dir = os.path.abspath(os.path.join(test_dir, '..', '..', '..', '..', '..', 'src'))

@cocotb.test()
async def test_s_box(dut):
    """S-box module testbench""" 
    iword = dut.iword
    oword = dut.oword
    dataset = [0xFDB97531, 0x2A196F34, 0xEBD9F03A, 0xB039BB3D, 0x68696433]

    for i in range(len(dataset)-1):
        iword.value = dataset[i]
        assert oword.value == dataset[i+1], f"S-box operation failed on {i+1} input value: output expected - {dataset[i+1]}, calculated - {oword.value}!"

def test_s_box_runner():
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
    test_s_box_runner()
