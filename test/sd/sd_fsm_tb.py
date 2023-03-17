import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, ClockCycles

import logging

import random

logging.basicConfig(level=logging.NOTSET)
logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

class SD_FSM_BFM():

    inputs = ["start", "cmd_done", "resp", "data_crc_fail", "data_done", "otp_ready"]
    outputs = ["sel_clk", "gen_otp", "new_otp", "start_cmd", "index", "arg", "start_d", "fail", "success"]

    def __init__(self):
        self.dut = cocotb.top

    async def start_operation(self):
        cocotb.start_soon(Clock(self.dut.iclk, 55, units="ns").start())

    async def reset_inputs(self):
        for i in self.inputs:
            setattr(getattr(self.dut, 'i'+ i), 'value', 0)

    async def reset(self):
        await FallingEdge(self.dut.iclk)
        self.dut.irst.value = 1 
        await self.reset_inputs() 
        await FallingEdge(self.dut.iclk)
        self.dut.irst.value = 0
        await FallingEdge(self.dut.iclk)

    async def set_inputs(self, input_values):
        await FallingEdge(self.dut.iclk)
        for i in self.inputs:
            setattr(getattr(self.dut, 'i'+ i), 'value', input_values[self.inputs.index(i)])

    async def check_outputs(self, output_values):
        return {o: int(getattr(getattr(self.dut, 'o' + o), 'value')) == output_values[self.outputs.index(o)] for o in self.outputs}

    async def random_delay(self, upper_bound):
        delay = random.randint(0,upper_bound)
        await ClockCycles(self.dut.iclk, delay)


@cocotb.test()
async def SD_FSM_tb(_):
    """SD controller FSM testbench""" 
    passed = True
    bfm = SD_FSM_BFM()
    await bfm.start_operation()
    await bfm.reset()
    with open('inputs.csv') as inputs:
        input_values = [[int(port) for port in input_value.rstrip().split(',')] for input_value in inputs]
    with open('outputs.csv') as outputs:
        output_values = [[int(port) for port in output_value.rstrip().split(',')] for output_value in outputs]

    for i in range(len(input_values)):
        await bfm.set_inputs(input_values[i])
        await FallingEdge(bfm.dut.iclk)
        outputs_ok = await bfm.check_outputs(output_values[i])
        for output in outputs_ok:
            if(outputs_ok[output]):
                logger.info(f"Output {output} after input {i} set correctly!") 
            else:
                logger.error(f"Output {output} after input {i} set incorrectly!") 
                passed = False
                break
        if(not passed):
            break
        await bfm.reset_inputs()
        await bfm.random_delay(10)
    assert passed

