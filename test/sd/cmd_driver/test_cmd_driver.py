#=========================================
# company: Tomsk State University
# developer: Simon Razenkov
# e-mail: sirazenkov@stud.tsu.ru
# description: CMD driver module testbench
#=========================================

import os
import cocotb
from cocotb.clock import Clock
from cocotb.runner import get_runner
from cocotb.triggers import FallingEdge, ClockCycles

from random import randint

test_dir = os.path.dirname(__file__)
rtl_dir = os.path.abspath(os.path.join(test_dir, '..', '..', '..', 'src'))

import sys
sys.path.append(os.path.join(test_dir, '../../'))
from common import crc7, Transaction, RCA, transactions

async def send_cmd(dut, index, arg):
    await FallingEdge(dut.iclk)
    dut.istart.value = 1
    dut.icmd_index.value = index
    dut.icmd_arg.value   = arg
    await FallingEdge(dut.iclk)
    if(int(dut.ocmd_sd_en.value) == 0):
        return False
    dut.istart.value = 0
    start_bit = int(dut.ocmd_sd.value)
    await FallingEdge(dut.iclk)
    transm_bit = int(dut.ocmd_sd.value)
    return start_bit == 0 and transm_bit == 1

async def check_cmd_field(dut, field, length):
    field_ok = True
    for i in range(length):
        await FallingEdge(dut.iclk)
        if(int(dut.ocmd_sd.value) != ((field >> (length-1-i)) & 1)):
            field_ok = False
    return field_ok

async def send_response(dut, index, resp, crc):
    if(index == 15):
        await FallingEdge(dut.iclk)
        return int(dut.odone.value)
    await FallingEdge(dut.iclk)
    if(int(dut.ocmd_sd_en.value) == 1):
        return 0
    dut.icmd_sd.value = 0
    await ClockCycles(dut.iclk, 2, rising=False)
    if(index == 2 or index == 9):
        dut.icmd_sd.value = 1
        for i in range(133):
            if(i < 6 or i == 50 or i == 52):
                dut.icmd_sd.value = 1
            else:
                dut.icmd_sd.value = 0
            await FallingEdge(dut.iclk)
    else:
        for i in range(6):
            if(index == 41):
                dut.icmd_sd.value = 1 
            else:
                dut.icmd_sd.value = 1 & (index >> (5-i))
            await FallingEdge(dut.iclk)
        for i in range(32):
            dut.icmd_sd.value = 1 & (resp >> (31-i)) 
            await FallingEdge(dut.iclk)
        for i in range(7):
            if(index == 41):
                dut.icmd_sd.value = 1 
            else:
                dut.icmd_sd.value = 1 & (crc >> (6-i))
            await FallingEdge(dut.iclk)
    dut.icmd_sd.value = 1
    await ClockCycles(dut.iclk, 9, rising=False) # Timeout between commands
    return int(dut.odone.value)

async def random_delay(dut, upper_bound):
    delay = randint(0,upper_bound)
    await ClockCycles(dut.iclk, delay)

@cocotb.test()
async def cmd_driver_tb(dut):
    """CMD line's driver testbench"""

    cocotb.start_soon(Clock(dut.iclk, 55, units="ns").start())

    await FallingEdge(dut.iclk)
    dut.irst.value     = 1 
    dut.icmd_sd.value  = 1
    dut.istart.value   = 0
    await FallingEdge(dut.iclk)
    dut.irst.value = 0
    await FallingEdge(dut.iclk)

    for trans in transactions:
        await random_delay(dut, 10)

        started = await send_cmd(dut, trans.index, trans.arg)
        assert started, f"Failed starting command {trans.index} transmission!"

        index_ok = await check_cmd_field(dut, trans.index, 6)
        assert index_ok, f"Failed receiving command index {trans.index}!"

        arg_ok = await check_cmd_field(dut, trans.arg, 32)
        assert arg_ok, f"Failed receiving command argument for (A)CMD{trans.index}!"

        crc_ok = await check_cmd_field(dut, trans.cmd_crc, 7)
        assert crc_ok, f"Failed CRC check for (A)CMD{trans.index}!"

        await FallingEdge(dut.iclk)
        assert int(dut.ocmd_sd.value) == 1, f"End bit not set after (A)CMD{trans.index}!"

        if (trans.index != 15):
            await random_delay(dut, 10)

        complete_resp = await send_response(dut, trans.index, trans.resp, trans.resp_crc)
        assert complete_resp, f"Failed sending response for command {trans.index}!"

def test_cmd_driver():
    sim = os.getenv("SIM", "icarus")

    verilog_sources = [os.path.join(rtl_dir, 'sd', 'cmd_driver', 'crc7.v'),
                       os.path.join(rtl_dir, 'sd', 'cmd_driver', 'cmd_driver.v')]
    runner = get_runner(sim)
    runner.build(
            verilog_sources=verilog_sources,
            hdl_toplevel="cmd_driver",
            always=True,
    )

    runner.test(hdl_toplevel="cmd_driver", test_module="test_cmd_driver",)

if __name__ == "__main__":
    test_cmd_driver()

