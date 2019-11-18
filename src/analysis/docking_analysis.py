#!/usr/bin/python3

import sys
import os
import matplotlib
import matplotlib.pyplot as plt
import numpy as np


def find_columns(headers):
	"""
	This function accepts the header line of the score file as input, and will return a dictionary that assocaites header/column names with their repsecitve indices
	This is to help make the code more abstract and prevent future issues/hardcoding
	"""

	index_store = {}

	# Split the header line of the file by white space... iterate through each header, and store the name and index in the dictionary
	for header, i in zip(headers.split(),range(len(headers.split()))):
		index_store[header]=i

	# return this dictionary
	return index_store


def read_score_file(score_file):
	
	try:
		with open(score_file,'r') as f:
			contents = f.readlines()
	except:
		print('Error reading file {}... are you in the right directory?'.format(score_file))
		sys.exit(1)
	
	index_store = find_columns(contents[1]) # pass in header line and recieve index dictionary

	# initialize the sum and count to get average
	sum_score = 0
	cnt = 0

	for line in contents[2:]: # Iterate through all but first two lines of the score file
		line = line.split()
		sum_score += float(line[index_store['I_sc']])
		cnt += 1

	return sum_score/cnt # return the average score.



if __name__ == "__main__":

	root = './docking/'

	sub_dirs = [x[1] for x in os.walk(root)]
	sub_dirs = sorted(sub_dirs[0])

	print('Found the following loop directories:')
	for sub in sub_dirs:
		print(sub)

	docking_avgs = []

	for folder in sub_dirs:
		try:
			avg = read_score_file(root + folder + '/output_files/score.sc')
			docking_avgs.append(avg)
		except:
			print('Error reached while reading file... Skipping to next')
			continue

	# for avg in docking_avgs:
	# 	print(avg)
	binwidth = 2
	bins = range(-30, 0 + binwidth, binwidth)
	
	dist_avg = np.average(docking_avgs)
	dist_med = np.median(docking_avgs)
	dist_std = np.std(docking_avgs)

	print('Descriptive Statistics:')
	print('-='*30)
	print('Average:\t',dist_avg)
	print('Median:\t\t',dist_med)
	print('Std:\t\t',dist_std)
	
	plt.hist(docking_avgs, bins=bins)
	plt.ylabel('Frequency (cnt)')
	plt.xlabel('Docking Interface Score (REU)')
	plt.title('Distribution of Interface Energies Between Fc and FcRn Proteins (n={})'.format(len(docking_avgs)))
	plt.show()
