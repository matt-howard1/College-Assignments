import socket
import threading
import Packet
import time

class WorkerConnection:

	def __init__(self, workerAddress, name, port):
		self.address = workerAddress
		self.name = name
		self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
		self.sock.bind(('localhost', port))
		self.ack = 0
		self.ackEvent = threading.Event()
		self.available = True
		self.listening = True
		self.listenThread = threading.Thread(target=self.listen)
		self.listenThread.start()
		print(f"Created connection to worker {name} at {self.address}")

	def listen(self):
		while self.listening:
			message, srcAddress = self.sock.recvfrom(Packet.MAX_SIZE)
			if srcAddress == self.address:
				print("From worker")
				packet = Packet.from_bytes(message)
				print(packet.to_string())
				self.process_worker_packet(packet)

	def process_worker_packet(self, packet):
		if packet.packetType == Packet.ACK:
			self.ack = packet.packetNumber
			self.ackEvent.set()
		elif packet.packetType == Packet.WORKER_CLOSE:
			self.listenThread.join()
			seklf.sock.close()
			removeWorker(self)
		elif packet.packetType == Packet.WORKER_AVAILABLE:
			self.available = True
		elif packet.packetType == Packet.WORKER_UNAVAILABLE:
			self.available = False
		elif packet.packetType == Packet.READY_TO_RECEIVE:
			self.listening = False
			self.ackEvent.set()
		elif packet.packetType == Packet.WORK_COMPLETE:
			ack = Packet.Packet(Packet.ACK)
			self.sock.sendto(ack.to_bytes(), self.address)
			results = Packet.receive_packet_list(self.sock, self.address, int(packet.data.split(' ')[0]))
			index = int(packet.data.split(' ')[1])
			add_results(results, index)

	def send_work(self, workPacket):

		timeout = 10.0

		packetNum = self.ack
		workPacket.packetNumber = packetNum

		print("Sending packet to worker...")

		self.sock.sendto(workPacket.to_bytes(), self.address)

		while not self.ackEvent.wait(timeout):
			print("Timeout. Sending packet again...")
			self.sock.sendto(workPacket.to_bytes(), self.address)
		
		self.ackEvent.clear()

		print(f"Received ack from {self.address}")

	def send_file(self, packets, index=0):

		timeout = 10.0

		fileDescription = Packet.Packet(Packet.FILE, 0, str(len(packets)) + ' ' + str(index))
		self.sock.sendto(fileDescription.to_bytes(), self.address)

		while not self.ackEvent.wait(timeout):
			print("Timeout. Sending packet again...")
			self.sock.sendto(fileDescription.to_bytes(), self.address)

		self.ackEvent.clear()

		Packet.send_packet_list(self.sock, self.address, packets)

		self.listening = True
		self.listenThread = threading.Thread(target=self.listen)
		self.listenThread.start()

	def confirm_availability(self):
		return self.available


class Broker:
	socket = None
	command = None
	workers = []
	resultBuffer = []
	resultBitSet = 0
	currentResults = 0
	fileBuffer = []
	RREvent = None
	sendingResults = False


def initialise_socket(port):
	result = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
	result.bind(('localhost', port))
	return result


def process_packet(packet, address, brokerSocket, lock, fileBuffer):
	
	pckt = Packet.from_bytes(packet)
	print(f"Received packet from {address}: {pckt.to_string()}")
	
	if pckt.packetType <= Packet.WORKER_VOLUNTEER:
		add_connection(pckt.packetType, address, brokerSocket, lock, pckt.data)
	elif pckt.packetType == Packet.READY_TO_RECEIVE:
		Broker.RREvent.set()
	else:
		send_ack(brokerSocket, address)
		if pckt.packetType == Packet.JOB_DESCRIPTION and address == Broker.command:
			send_work(pckt, brokerSocket, fileBuffer)


def add_connection(connectionType, address, brokerSocket, lock, name):
	if connectionType == Packet.CC_CONNECT:
		
		print(f"Connection from command at {address}")
		
		response = Packet.Packet(Packet.ACK)
		
		if Broker.command is None:
			Broker.command = address
		else:
			response.packetType = Packet.CC_DECLINE
		
		brokerSocket.sendto(response.to_bytes(), address)
	
	elif connectionType == Packet.WORKER_VOLUNTEER:
				
		response = Packet.Packet(Packet.ACK)
		print(f"Connection from worker {name} at {address}")
		with lock:

			port = 12346 + len(Broker.workers)
			worker = WorkerConnection(address, name, port)
			Broker.workers.append(worker)
			response.data = '127.0.0.1' + ':' + str(port)

		brokerSocket.sendto(response.to_bytes(), address)


def send_work(workDescription, brokerSocket, filePackets):

	dataSplit = workDescription.data.split(' ')

	availableWorkers = []

	for worker in Broker.workers:
		if worker.confirm_availability():
			availableWorkers.append(worker)

	numWorkers = len(availableWorkers)

	if 'SENDTO' in dataSplit:
		try:
			index = dataSplit.index('SENDTO')
			numWorkers = int(dataSplit[index + 1])
			del dataSplit[index + 1]
			del dataSplit[index]
			workDescription.data = ' '.join(dataSplit)
		except (TypeError, IndexError, ValueError) as error:
			print("Invalid command: No number specified for SENDTO flag")
			numWorkers = 0

	if numWorkers != 0:
		if numWorkers > len(availableWorkers):
			numWorkers = len(availableWorkers)
		if 'FINDKEY' in dataSplit:
			interval = int(dataSplit[-1]) // numWorkers
			print(f"Interval: {interval}")
			currentStart = 0
			print(f"Sending work to {numWorkers} workers...")
			for worker in availableWorkers[0:numWorkers]:
				if worker.confirm_availability():
					dataSplit.insert(1, str(currentStart))
					dataSplit.insert(2, str(currentStart + interval))
					print(dataSplit)
					currentStart += interval
					workDescription.data = ' '.join(dataSplit)
					del dataSplit[1]
					del dataSplit[1]
					worker.send_work(workDescription)
		elif dataSplit[0] == "XOR":
			if filePackets is not None:
				Broker.resultBitSet = 2**numWorkers - 1
				print("result bit set: " + str(Broker.resultBitSet))
				packetsPerWorker = len(filePackets)//numWorkers
				index = 0
				for worker in availableWorkers[0:numWorkers]:
					start = packetsPerWorker * index
					end = packetsPerWorker * (index + 1)
					if index == numWorkers - 1:
						worker.send_file(filePackets[packetsPerWorker * index:], index)
					else:
						worker.send_file(filePackets[start:end], index)
					worker.send_work(workDescription)
					index += 1

		else:
			print("Sending work...")
			for worker in availableWorkers[0:numWorkers]:
				if worker.confirm_availability():
					worker.send_work(workDescription)

def add_results(results, index=0):
	Broker.resultBuffer.extend(results)
	print("Index: " + str(index))
	Broker.currentResults = Broker.currentResults | (1<<index)
	print("Current results: " + str(Broker.currentResults))
	if Broker.currentResults == Broker.resultBitSet:
		send_results()

def send_results():
	print("Sending results...")
	Broker.sendingResults = True
	Broker.socket.sendto(Packet.Packet(Packet.WORK_COMPLETE, 0, str(len(Broker.resultBuffer))).to_bytes(), Broker.command)

	while not Broker.RREvent.wait(10):
		print("Timeout, sending packet again...")
		Broker.socket.sendto(Packet.Packet(Packet.WORK_COMPLETE, 0, str(len(Broker.resultBuffer))).to_bytes(), Broker.command)

	Broker.RREvent.clear()

	print("Sending files...")
	Packet.send_packet_list(Broker.socket, Broker.command, Broker.resultBuffer)
	Broker.sendingResults = False

def removeWorker(worker):
	workers.remove(worker)

def receive_file(socket, source, packetCount):
	packets = Packet.receive_packet_list(socket, source, packetCount)
	return packets

def send_ack(socket, destination, ackNumber=0):
	ackPacket = Packet.Packet(Packet.ACK, ackNumber)
	socket.sendto(ackPacket.to_bytes(), destination)

def receive_packet(socket):
	try:
		packet, address = socket.recvfrom(Packet.MAX_SIZE)
		return packet, address
	except:
		return None, None


if __name__ == "__main__":

	sock = initialise_socket(12345)
	Broker.socket = sock
	Broker.RREvent = threading.Event()
	workerLock = threading.Lock()

	running = True
	while running:
		packet, address = receive_packet(sock)
		if packet is not None and address is not None:
			if Packet.from_bytes(packet).packetType == Packet.FILE:
				numPackets = int(Packet.from_bytes(packet).data)
				send_ack(sock, Broker.command)
				Broker.fileBuffer = receive_file(sock, Broker.command, numPackets)
			else:
				thread = threading.Thread(target=process_packet, args=(packet, address, sock, workerLock, Broker.fileBuffer))
				thread.start()
		while Broker.sendingResults:
			time.sleep(1)

	sock.close()