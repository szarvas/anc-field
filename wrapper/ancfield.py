# -*- coding: utf-8 -*-
"""
Copyright 2014 Attila Szarvas

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
"""

from __future__ import division
import os.path
import numpy as np
import hashlib
from winpexpect import winspawn as spawn
from subprocess import Popen, PIPE, STDOUT
import re

EXE_PATH = '../anc-field/build/anc-field.exe'
#EXE_PATH = '../anc-field/build/anc-field.exe'

class AncField:
	#fs = 29593
	fs = 32000

	def __init__(self, device, model=None, minsize=None, exeloc=EXE_PATH):
		if not device == 'gpu' and not device == 'cpu':
			raise Exception('Device is either \'gpu\' or \'cpu\'')

		if model != None:
			if not os.path.exists(model+'/model.xml'):
				raise Exception(model+' is not a valid model location')

		if not os.path.exists(exeloc):
			raise Exception('Location \''+exeloc+'\' doesn\'t exist')

		self.command = 'sdt '+device+'\n'

		if model != None:
			self.command += 'load '+model+'/model.xml\n'

		if minsize != None:
			self.command += 'minsize [' + str(minsize[0]) + ',' + str(minsize[1]) + ',' + str(minsize[2]) + ']\n'

		self.exeloc = exeloc
		self.mics = []
		self.inputs = []
		self.pos_inputs = []
		self.stdout_data = None

	def Pml(self, width):
		self.command += 'pml ' + str(width) + '\n'

	def AddMic(self, position):
		self.mics += [position]

	def AddSource(self, pos, data):
		if not os.path.isdir('.ancfield'):
			os.makedirs('.ancfield')
		filename = '.ancfield/'+hashlib.md5(data).hexdigest()+'.dat'
		if not os.path.isfile(filename):
			np.savetxt(filename, data)
		self.command += 'addsource ['+str(pos[0])+','+str(pos[1])+','+str(pos[2])+'] '+filename+'\n'
		self.inputs.append(data)
		self.pos_inputs.append(pos)

	def Run(self, length):
		for e in self.inputs:
			if np.size(e) < length/self.fs:
				raise Exception('Input shorter than simulation interval')

		for m in self.mics:
			self.command += 'addmic ['+str(m[0])+','+str(m[1])+','+str(m[2])+']\n'
		self.command += 'run '+str(length)+'\n'

		if len(self.mics) > 0:
			if not os.path.isdir('.ancfield'):
				os.makedirs('.ancfield')
#			self.command += 'save .ancfield/output.dat\nquit\n'

		if 'vis' in self.command:
#			vlc = Popen('vlc/VlcPortable.exe http://localhost:1440/live --qt-minimal-view')
			vlc = Popen(r"C:\Program Files (x86)\VideoLAN\VLC\vlc.exe http://localhost:1440/live --qt-minimal-view")

		print(self.command)
		child = spawn(EXE_PATH)
		child.expect('>>')
		for line in self.command.split('\n'):
			if len(line) > 1:
				child.sendline(line)

		child.expect('BEGIN')

		while True:
			line = child.readline()
			m = re.search('(\d+)/(\d+)', line)
			if m != None:
				print(int(m.group(1)) / int(m.group(2)))

				if int(m.group(1)) == int(m.group(2)):
					break

		if 'vis' in self.command:
			vlc.kill()

		try:
			child.sendline('save .ancfield/output.dat\nquit\n')
		except:
			pass

#		p = Popen([self.exeloc], stdout=PIPE, stdin=PIPE, stderr=PIPE)
#		self.stdout_data = p.communicate(input=self.command)[0]

 		if len(self.mics) > 0:
 			output_data = np.loadtxt('.ancfield/output.dat')

 		input_data = np.zeros(length*self.fs)

 		for i in self.inputs:
 			input_data = np.vstack([input_data, i[0:length*self.fs]])

 		return (input_data[1:,:], output_data)

	def Visualize(self, level):
		self.command += 'vis '+str(level)+'\n'
