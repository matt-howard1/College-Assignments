import socket
import Packet
import time


def initialise_worker():
	name = input("Enter name: ")
	availability = (input("Available to work (y/n): ").lower() == "y")
	sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
	return sock, name, availability


def connect_to_broker(socket, name):
	pack = Packet.Packet(Packet.WORKER_VOLUNTEER, data=name)
	print("Connecting to localhost:12345")
	s.sendto(pack.to_bytes(), ('localhost', 12345))
	response, address = socket.recvfrom(Packet.MAX_SIZE)
	responsePacket = Packet.from_bytes(response)
	print(f"Response: {responsePacket.to_string()}")
	addressSplit = responsePacket.data.split(':')
	return (addressSplit[0], int(addressSplit[1]))


def process_packet(packet, socket, availability, source):
	
	if packet.packetType == Packet.JOB_DESCRIPTION:
		
		print("Sending ACK...")
		socket.sendto(Packet.Packet(Packet.ACK, 0).to_bytes(), source)
		#ack ^= 1
		print(packet.data)
		commandSplit = packet.data.split(' ')
		
		if commandSplit[0] == "PRINT":
			print(' '.join(commandSplit[1:]))
		
		elif commandSplit[0] == "FINDKEY":
			keys = search_for_key(int(commandSplit[1]), int(commandSplit[2]), commandSplit[3], " ".join(commandSplit[4:-1]), int(commandSplit[-1]))
			print(keys)
			workResult = Packet.Packet(Packet.WORK_COMPLETE, data=(", ".join([str(key) for key in keys])))
			print(workResult.to_string())
			send_results([workResult], source, socket)

		elif commandSplit[0] == "XOR":
			result = xor_encrypt_buffer(commandSplit[1:])
			send_results(result, source, socket)

	elif packet.packetType == Packet.FILE:
		
		packetCount, index = (int(s) for s in packet.data.split(' '))
		socket.sendto(Packet.Packet(Packet.READY_TO_RECEIVE, 0).to_bytes(), source)
		packets = Packet.receive_packet_list(socket, source, packetCount)

		add_to_buffer(packets, index)


	elif packet.packetType == Packet.CHECK_AVAILABLE:
		
		if availability:
			socket.sendto(Packet.Packet(Packet.WORKER_AVAILABLE).to_bytes(), source)
		else:
			socket.sendto(Packet.Packet(Packet.WORKER_UNAVAILABLE).to_bytes(), source)

def add_to_buffer(packets, index):
	global filebuffer
	global fileIndex
	filebuffer.extend(packets)
	fileIndex = index

def xor_encrypt_buffer(key):
	global filebuffer
	print(key)
	intKey = [int(k) for k in key]
	print(intKey)
	data = [packet.data for packet in filebuffer]
	result = []
	byte = 0
	for string in data:
		xorString = ""
		for char in string:
			xorString += chr(ord(char) ^ intKey[byte])
			byte += 1
			byte %= len(key)
		result.append(Packet.Packet(Packet.FILE, 0, ''.join(xorString)))
	return result

def send_results(packets, destination, socket):
	global fileIndex
	workNotification = Packet.Packet(Packet.WORK_COMPLETE, 0, str(len(packets)) + ' ' + str(fileIndex))
	socket.sendto(workNotification.to_bytes(), destination)

	response, address = socket.recvfrom(Packet.MAX_SIZE)

	response = Packet.from_bytes(response)

	if address == source and response.packetType == Packet.ACK:
		Packet.send_packet_list(socket, destination, packets)


def search_for_key(start: int, end: int, encrypted: str, expected: str, keySize: int):
	
	possibleKey = bytearray([0 for i in range(0, keySize)])

	possibleKey[start:end] = bytearray([0xFF for i in range(0, start)])

	encrypted = bytes([ord(c) for c in encrypted])

	encodedMessage = [ord(c) for c in expected]

	currentIndex = start

	while currentIndex < len(possibleKey):
		for i in range(0, 255):
			for x in range(0, len(possibleKey)):
				if x == currentIndex:
					print(i, end=" ")
				else:
					print(possibleKey[x], end=" ")
			print(end="\r")
			if encrypted[currentIndex] ^ i == encodedMessage[currentIndex]:
				possibleKey[currentIndex] = i
				currentIndex += 1
				break
			time.sleep(0.05)

	return possibleKey


filebuffer = []
fileIndex = 0

if __name__ == "__main__":
	s, name, availability = initialise_worker()

	if availability:
		print("Available for work")
	else:
		print("Unavailable for work")

	brokerAddress = connect_to_broker(s, name)
	print(brokerAddress)

	ack = 0

	while True:
		work, source = s.recvfrom(Packet.MAX_SIZE)
		print(f"Packet from {source}:")
		if source == brokerAddress:
			pckt = Packet.from_bytes(work)
			process_packet(pckt, s, availability, source)

	s.close()