CC_CONNECT = 0b0000
WORKER_VOLUNTEER = 0b0001
JOB_DESCRIPTION = 0b0010
CC_DECLINE = 0b0011
ACK = 0b0100
CC_CLOSE = 0b0101
WORKER_CLOSE = 0b0110
WORKER_DECLINE = 0b0111
CHECK_AVAILABLE = 0b1000
WORKER_AVAILABLE = 0b1001
WORKER_UNAVAILABLE = 0b1010
WORK_COMPLETE = 0b1011
FILE = 0b1100
READY_TO_RECEIVE = 0b1101
MAX_SIZE = 64

type_string = ["CC connect", "Worker", "Job", "CC decline", "Ack", "CC close", "Worker close", "Worker decline", "Check availability", "Worker available", "Worker unavailable", "Work complete", "File", "READY_TO_RECEIVE"]

class Packet:

	def __init__(self, packetType, packetNumber=0, data=""):
		self.packetType = packetType
		self.packetNumber = packetNumber
		self.data = data

	def to_bytes(self):
		result = bytearray([self.packetType])
		result.append(self.packetNumber & 0b1111)
		result.extend(bytes(self.data, 'utf-8'))
		return result

	def to_string(self):
		string = type_string[self.packetType] +  ", " + str(self.packetNumber)
		if len(self.data) > 0:
			string += ", " + self.data
		return string

def from_bytes(bytePacket):
		packetType = bytePacket[0]
		packetNumber = bytePacket[1]
		data = bytePacket[2:].decode('utf-8')
		packet = Packet(packetType, packetNumber, data)
		return packet

def packetise_file(file):
	packets = [Packet(FILE, 0, x.decode('unicode_escape')) for x in split_list(file, MAX_SIZE - 4)]
	return packets

def split_list(list, size):
	for split in range(0, len(list), size):
		yield list[split:split + size]

def send_file(socket, destination, filename):
	
	try:
		file = open(filename, 'rb').read()
		packets = packetise_file(file)
		prefix = Packet(FILE, 0, str(len(packets)))	#Insert packet at start of packet list to signal that a file is about to be sent

		socket.sendto(prefix.to_bytes(), destination)

		response, address = socket.recvfrom(MAX_SIZE)

		if address == destination and from_bytes(response).packetType == ACK:
			send_packet_list(socket, destination, packets)
	except FileNotFoundError:
		print(f"Could not open file {filename}: No such file found.")
	
	
def send_packet_list(socket, destination, packets):

	nextAck = 1
	index = 0
	total = len(packets)
	
	for packet in packets:
		packet.packetNumber = nextAck ^ 1
		
		progressBar = "".join(['=' for i in range(0, int(index/total * 50))]) + "".join(['-' for i in range(int(index/total * 50), 49)])
		print(f"Sending packet {index + 1}/{total}\t |{progressBar}|", end="\r")
		
		sendingPacket = True
		while sendingPacket:
			
			socket.sendto(packet.to_bytes(), destination)
			response, source = socket.recvfrom(MAX_SIZE)	#Wait for ACK from broker
			
			if source == destination:
				pack = from_bytes(response)
				if pack.packetNumber == nextAck:
					nextAck ^= 1
					sendingPacket = False	#Packet has been sent successfully, exit loop
					index+=1

	print("\nDone.")

def receive_packet_list(socket, source, count):
	print("Incoming...")
	index = 0
	packets = []
	ack = 0
	while index < count:
		filePack, address = socket.recvfrom(MAX_SIZE)
		filePack = from_bytes(filePack)
		if address == source and filePack.packetNumber == ack:
			packets.append(filePack)
			ack ^= 1
			response = Packet(ACK, packetNumber=ack)
			socket.sendto(response.to_bytes(), source)
			string = "".join(['=' for i in range(0, int((index/count) * 50))]) + "".join(['-' for i in range(int((index/count) * 50), 49)])
			print(f"Received packet {index}/{count}\t |{string}|", end="\r")
			index += 1
	print("\nDone.")
	return packets