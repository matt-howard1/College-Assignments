import socket
import Packet

def receive_results(socket, source, workType):
	resultPacket = wait_for_packet(socket, source, Packet.WORK_COMPLETE)
	print("Received results: " + resultPacket.to_string())
	if workType == "XOR":
		packetCount = int(resultPacket.data)
		socket.sendto(Packet.Packet(Packet.READY_TO_RECEIVE).to_bytes(), source)
		results = Packet.receive_packet_list(socket, source, packetCount)
		resultFile = open("output.txt", "w+")
		for packet in results:
			resultFile.write(packet.data)
		resultFile.close()

def parse_command(command, socket, destination):
	
	commandSplit = command.split(' ')
	work = commandSplit[0]
	parameters = commandSplit[1:]
	
	if work == "PRINT":
		
		if len(parameters) == 0:
			print("Invalid usage of command 'PRINT'. Usage: PRINT <string>")
		
		else:
			workerCount = input("Enter the number of workers to send the work to (ALL for every worker): ")
			if workerCount.upper() == "ALL":
				send_work(Packet.Packet(Packet.JOB_DESCRIPTION, data=command), socket, destination)
			elif workerCount.isnumeric():
				send_work(Packet.Packet(Packet.JOB_DESCRIPTION, data=(command + " SENDTO " + workerCount)), socket, destination)
			else:
				print("Invalid entry")

	elif work == "DECRYPT" or work == "ENCRYPT":
		
		if len(parameters) < 2:
			print(f"Invalid usage of command '{work}'. Usage: {work} <filename> <key>")
		
		else:
			Packet.send_file(socket, destination, parameters[0])
			workerCount = input("Enter the number of workers to send the work to (ALL for every worker): ")
			if workerCount.upper() == "ALL":
				workDescription = Packet.Packet(Packet.JOB_DESCRIPTION, 0, "XOR " + ' '.join(parameters[1:]))
				send_work(workDescription, socket, destination)
				receive_results(socket, destination, "XOR")
			elif workerCount.isnumeric():
				workDescription = Packet.Packet(Packet.JOB_DESCRIPTION, 0, "XOR " + ' '.join(parameters[1:]) + " SENDTO " + workerCount)
				send_work(workDescription, socket, destination)
				receive_results(socket, destination, "XOR")
			else:
				print("Invalid entry")
	
	elif work == "FINDKEY":
		
		if len(parameters) != 3:
			print("Invalid usage of command 'FINDKEY'. Usage: FINDKEY <encrypted> <expected> <key length>")
		else:
			send_work(Packet.Packet(Packet.JOB_DESCRIPTION, data=command), socket, destination)
			workerCount = input("Enter the number of workers to send the work to (ALL for every worker): ")
			if workerCount.upper() == "ALL":
				send_work(Packet.Packet(Packet.JOB_DESCRIPTION, data=command), socket, destination)
			elif workerCount.isnumeric():
				send_work(Packet.Packet(Packet.JOB_DESCRIPTION, data=(command + " SENDTO " + workerCount)), socket, destination)
			else:
				print("Invalid entry")



def send_work(workPacket, socket, destination):
	
	socket.sendto(workPacket.to_bytes(), destination)

	while wait_for_packet(socket, destination, Packet.ACK, 10) is None:
		print("Sending packet again...")
		socket.sendto(workPacket.to_bytes(), destination)

	print("Received ack")


def wait_for_packet(socket, source, packetType, timeout=None):
	
	socket.settimeout(timeout)

	try:
		response, address = socket.recvfrom(Packet.MAX_SIZE)
		if Packet.from_bytes(response).packetType == packetType and address == source:
			socket.settimeout(None)
			return Packet.from_bytes(response)
		elif Packet.from_bytes(response).packetType != packetType:
			print("Invalid packet type: "+ Packet.from_bytes(response).to_string())
			return None
	except TimeoutError:
		print("Connection timeout")
		socket.settimeout(None)
		return None


def initialise_socket():
	try:
		s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
		return s
	except:
		print("Could not initialise socket.")

def connect_to_broker():
	pack = Packet.Packet(Packet.CC_CONNECT)
	print("Connecting to localhost:12345")
	s.sendto(pack.to_bytes(), ('localhost', 12345))
	response, address = s.recvfrom(Packet.MAX_SIZE)
	response = Packet.from_bytes(response)
	return response, address

s = initialise_socket()
response, broker = connect_to_broker()
print(f"Response: {response.to_string()}")

if response.packetType != Packet.CC_DECLINE:
	running = True

	while running:

		message = input("Enter message: ")
		if message != "quit":
			parse_command(message, s, broker)
		else: 
			running = False

s.close()