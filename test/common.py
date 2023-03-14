def crc7(data):
    crc = 0
    for i in range(39): # transmission bit + command index (6 bits) + command argument (32 bits)
        data_bit = (data >> (38-i)) & 1
        last_bit = (crc >> 6) & 1
        xor_bit = last_bit ^ data_bit
        crc = crc << 1
        crc = crc & ((1 << 7) - 1)
        crc = crc ^ xor_bit ^ (xor_bit << 3)
    return crc

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

def gen_crc16_packets(block):
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
