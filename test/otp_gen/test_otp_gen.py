#====================================================
#company: Tomsk State University
#developer: Simon Razenkov
#e-mail: sirazenkov@stud.tsu.ru
#description: One-time pad generator module testbench
#====================================================

import os
import cocotb
from cocotb.runner import get_runner
from cocotb.triggers import Timer, RisingEdge, FallingEdge, with_timeout
from cocotb.clock import Clock

test_dir = os.path.dirname(__file__)
rtl_dir = os.path.abspath(os.path.join(test_dir, '..', '..', 'src'))

@cocotb.test()
async def otp_gen_tb(dut):
    """One-time pad generator module testbench""" 
    istart = dut.istart
    dut.ikey.value = int('FFEEDDCCBBAA99887766554433221100F0F1F2F3F4F5F6F7F8F9FAFBFCFDFEFF', 16)
    dut.iIV.value = 0
    dut.inew_otp.value = 0

    cocotb.start_soon(Clock(dut.iclk, 40, units="ns").start())

    await FallingEdge(dut.iclk) 
    istart.value = 1
    await FallingEdge(dut.iclk) 
    istart.value = 0 

    counter = 0
    size = 1024 * 8 # RAM block size * RAM_BLOCKS
    while(counter < size):
        await with_timeout(RisingEdge(dut.owrite_en), 6000, 'ns')
        for i in range(16):
            await FallingEdge(dut.iclk) 
            address = int(dut.osel_ram.value) << 10 | int(dut.oaddr.value)
            assert (address == counter) and int(dut.owrite_en) == 1, f"OTP write failed for address {counter}"
            counter = counter + 1
    
    assert int(dut.odone.value) == 1, "Done signal not set" 

def test_otp_gen():
    sim = os.getenv("SIM", "icarus")

    verilog_sources = [os.path.join(rtl_dir, 'otp_gen', 'gost', 'round', 's_box.v'),
                       os.path.join(rtl_dir, 'otp_gen', 'gost', 'round', 'round.v'),
                       os.path.join(rtl_dir, 'otp_gen', 'gost', 'gost.v'),
                       os.path.join(rtl_dir, 'otp_gen', 'otp_gen.v')]
    runner = get_runner(sim)
    runner.build(
            verilog_sources=verilog_sources,
            hdl_toplevel="otp_gen",
            always=True,
    )

    runner.test(hdl_toplevel="otp_gen", test_module="test_otp_gen",)

if __name__ == "__main__":
    test_otp_gen()

