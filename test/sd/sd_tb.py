import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, ClockCycles

import logging

import random

NUM_OF_TRANSACTIONS = 5

logging.basicConfig(level=logging.NOTSET)
logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

class D_driver_BFM():
    def __init__(self):
        self.dut = cocotb.top

    async def start_operation(self):
        cocotb.start_soon(Clock(self.dut.iclk, 55, units="ns").start())
        cocotb.start_soon(self.ram())

    async def reset(self):
        await FallingEdge(self.dut.iclk)
        self.dut.irst.value     = 1 
        self.dut.idata_sd.value = 0xF
        self.dut.istart.value   = 0
        await FallingEdge(self.dut.iclk)
        self.dut.irst.value = 0
        await FallingEdge(self.dut.iclk)

    async def ram(self):
        mem = [0 for i in range(1024)]
        while(True):
            await RisingEdge(self.dut.iclk)
            if(int(self.dut.owrite_en.value) == 1):
                mem[int(self.dut.oaddr.value)] = int(self.dut.owdata.value)
            self.dut.irdata.value = mem[int(self.dut.oaddr.value)]

    async def send_block(self, block, crc_packets):
        await FallingEdge(self.dut.iclk)
        self.dut.istart.value = 1
        await FallingEdge(self.dut.iclk)
        self.dut.idata_sd.value = 0 # Start bit
        self.dut.istart.value = 0
        await FallingEdge(self.dut.iclk)
        for i in range(1024):
            self.dut.idata_sd.value = block[i]
            await FallingEdge(self.dut.iclk)
        for i in range(16):
            self.dut.idata_sd.value = crc_packets[i]
            await FallingEdge(self.dut.iclk)
        self.dut.idata_sd.value = 0xF # End bit
        await RisingEdge(self.dut.odone)
        await FallingEdge(self.dut.iclk)

    async def receive_block(self, crc_packets):
        await FallingEdge(self.dut.iclk)
        self.dut.istart.value = 1
        await FallingEdge(self.dut.iclk)
        self.dut.istart.value = 0
        await FallingEdge(self.dut.iclk)
        block = []
        for i in range(1024):
            block.append(int(self.dut.odata_sd))
            await FallingEdge(self.dut.iclk)
        crc_failed = False
        for i in range(16):
            if(int(self.dut.odata_sd.value) != crc_packets[i]):
                crc_failed = True
            await FallingEdge(self.dut.iclk)
        await RisingEdge(self.dut.odone)
        return (block, crc_failed)

    async def random_delay(self, upper_bound):
        delay = random.randint(0,upper_bound)
        await ClockCycles(self.dut.iclk, delay)


def crc16(data):
    crc = 0
    for i in range(1024): 
        data_bit = (data >> (1023-i)) & 1
        last_bit = (crc >> 15) & 1
        xor_bit = last_bit ^ data_bit
        crc = crc << 1
        crc = crc & ((1 << 16) - 1)
        crc = crc ^ xor_bit ^ (xor_bit << 5) ^ (xor_bit << 12)
    return crc

def gen_crc_packets(block):
    lines_data = [0,0,0,0]
    for i in range(1024):
        for j in range(4):
            lines_data[j] = lines_data[j] << 1 | ((block[i] >> j) & 1)
    crc_values = [crc16(line_data) for line_data in lines_data]
    crc_packets = []
    for i in range(16):
        crc_packet = 0
        for j in range(4):
            crc_packet = crc_packet | (((crc_values[j] >> (15-i)) & 1) << j)
        crc_packets.append(crc_packet)
    return crc_packets

#@cocotb.test()
async def sd_tb(_):
    """SD controller testbench""" 
    passed = True
    bfm = D_driver_BFM()
    await bfm.start_operation()
    await bfm.reset()

    for i in range(NUM_OF_TRANSACTIONS):
        block = [random.randint(0,15) for i in range(1024)]
        crc_packets = gen_crc_packets(block)
        await bfm.random_delay(10)
        await bfm.send_block(block, crc_packets)
        if(int(bfm.dut.ocrc_fail.value) == 0):
            logger.info(f"CRC16 check for block {i} succeeded!")
        else:
            logger.error(f"CRC16 check for block {i} failed!")
            passed = False
            break
        if(int(bfm.dut.odone.value) == 1):
            logger.info(f"Module received block {i} successfully!") 
        else:
            logger.error(f"Module did not receive block {i} successfully!")
            passed = False
            break
        await bfm.random_delay(10)
        received_block, crc_failed = await bfm.receive_block(crc_packets)
        if(block == received_block):
            logger.info(f"Block {i} from module is equal the initial block {i}!") 
        else:
            logger.error(f"Block {i} from module does not equal the initial block {i}!")
            passed = False
            break
        if(not crc_failed):
            logger.info(f"Correct CRC in block {i} from the module!")
        else:
            logger.error(f"Wrong CRC in block {i} from the module!")
            break
        if(int(bfm.dut.odata_sd.value) == 0xF):
            logger.info(f"Finish bit set in block {i} from module!") 
        else:
            logger.error(f"Finish bit not set in block {i} from module!")
            passed = False
            break
    assert passed

