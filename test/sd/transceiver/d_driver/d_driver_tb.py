import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge

import logging

import random

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
        logger.info("Started resetting")
        await FallingEdge(self.dut.iclk)
        self.dut.irst.value     = 1 
        self.dut.idata_sd.value = 1
        self.dut.istart.value   = 0
        await FallingEdge(self.dut.iclk)
        self.dut.irst.value = 0
        await FallingEdge(self.dut.iclk)

    async def ram(self):
        mem = [0 for i in range(1024)]
        while(True):
            await FallingEdge(self.dut.iclk)
            if(int(self.dut.owrite_en.value) == 1):
                mem[int(self.dut.oaddr.value)] = int(self.dut.owdata.value)
            self.dut.irdata.value = mem[int(self.dut.oaddr.value)]

    def crc16(self, data):
        crc = 0
        for i in range(1024): 
            data_bit = (data >> (1023-i)) & 1
            last_bit = (crc >> 15) & 1
            xor_bit = last_bit ^ data_bit
            crc = crc << 1
            crc = crc ^ xor_bit ^ (xor_bit << 5) ^ (xor_bit << 12)
        return crc

    def crc_packets(self, block):
        lines_data = [0,0,0,0]
        for i in range(1024):
            for j in range(4):
                lines_data[j] = lines_data[j] << 1 | ((block[i] >> j) & 1)
        crc_values = [self.crc16(line_data) for line_data in lines_data]
        crc_packets = []
        for i in range(16):
            crc_packet = 0
            for j in range(4):
                crc_packet = crc_packet | (((crc_values[j] >> (16-i)) & 1) << j)
            crc_packets.append(crc_packet)
        return crc_packets

    async def send_block(self, block):
        logger.info("Started sending")
        self.dut.istart.value = 1
        await FallingEdge(self.dut.iclk)
        self.dut.idata_sd.value = 0 # Start bit
        self.dut.istart.value = 0
        await FallingEdge(self.dut.iclk)
        for i in range(1024):
            self.dut.idata_sd.value = block[i]
            await FallingEdge(self.dut.iclk)
        crc_packets = self.crc_packets(block)
        for i in range(16):
            await FallingEdge(self.dut.iclk)
            self.dut.idata_sd.value = crc_packets[i]
        await FallingEdge(self.dut.iclk)
        self.dut.idata_sd.value = 0xF # End bit
        await FallingEdge(self.dut.iclk)

    async def receive_block(self):
        logger.info("Started receiving")
        self.dut.istart.value = 1
        while(self.dut.odata_sd.value != 0): # Start bit
            await FallingEdge(self.dut.iclk)
        self.dut.istart.value = 0
        block = []
        for i in range(1024):
            await FallingEdge(self.dut.iclk)
            block.append(int(self.dut.odata_sd))
        await FallingEdge(self.dut.iclk)
        return block
 
@cocotb.test()
async def d_driver_tb(_):
    """D line's driver testbench""" 
    passed = True
    bfm = D_driver_BFM()
    await bfm.start_operation()
    await bfm.reset()

    transactions = random.randint(0,5)
    for i in range(transactions):
        block = [random.randint(0,15) for i in range(1024)]
        await bfm.send_block(block)
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
        received_block = await bfm.receive_block()
        if(int(bfm.dut.odata_sd.value) == 0xF):
            logger.info(f"Finish bit set in block {i}!") 
        else:
            logger.error(f"Finish bit not set in block {i}!")
            passed = False
            break
        if(block == received_block):
            logger.info(f"Received block {i} is equal the initial block {i}!") 
        else:
            logger.error(f"Received block {i} does not equal the initial block {i}!")
            passed = False
            break
    assert passed

