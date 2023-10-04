#================================================
# company: Tomsk State University
# developer: Simon Razenkov
# e-mail: sirazenkov@stud.tsu.ru
# description: SD controller FSM module testbench
#================================================

import os
import cocotb
from cocotb.clock import Clock
from cocotb.runner import get_runner
from cocotb.triggers import FallingEdge, ClockCycles

test_dir = os.path.dirname(__file__)
rtl_dir = os.path.abspath(os.path.join(test_dir, '..', '..', 'src'))

from random import randint

from sequence import *

async def reset(dut):
    await FallingEdge(dut.iclk)
    dut.irst.value = 1 
    await FallingEdge(dut.iclk)
    dut.irst.value = 0
    await FallingEdge(dut.iclk)

async def reset_inputs(dut):
    for i in inputs:
        setattr(getattr(dut, 'i'+ i), 'value', 0)

async def set_inputs(dut, input_values):
    await FallingEdge(dut.iclk)
    for i in range(len(inputs)):
        setattr(getattr(dut, 'i'+ inputs[i]), 'value', input_values[i])

async def check_outputs(dut, output_values):
    return {outputs[i]: int(getattr(getattr(dut, 'o' + outputs[i]), 'value')) == output_values[i] for i in range(len(outputs))}

async def random_delay(dut, upper_bound):
    delay = randint(0, upper_bound)
    await ClockCycles(dut.iclk, delay)

@cocotb.test()
async def SD_FSM_tb(dut):
    """SD controller FSM testbench""" 

    cocotb.start_soon(Clock(dut.iclk, 55, units="ns").start())

    await reset_inputs(dut)

    await reset(dut)

    for i in range(len(ivalues)):
        await set_inputs(dut, ivalues[i])
        await FallingEdge(dut.iclk)
        outputs_ok = await check_outputs(dut, ovalues[i])
        for output in outputs_ok:
            assert outputs_ok[output], f"Output {output} after input {i+1} set incorrectly!"
        if (int(dut.ofail.value)):
            await reset(dut)
        await reset_inputs(dut)
        await random_delay(dut, 10)

def test_sd_fsm():
    sim = os.getenv("SIM", "icarus")

    verilog_sources = [os.path.join(rtl_dir, 'sd', 'sd_fsm.v')]
    runner = get_runner(sim)
    runner.build(
            verilog_sources=verilog_sources,
            hdl_toplevel="sd_fsm",
            always=True,
    )

    runner.test(hdl_toplevel="sd_fsm", test_module="test_sd_fsm",)

if __name__ == "__main__":
    test_sd_fsm()

