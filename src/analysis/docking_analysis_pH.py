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
	scores = []
	sum_score = 0
	cnt = 0

	for line in contents[2:]: # Iterate through all but first two lines of the score file
		line = line.split()
		scores.append(float(line[index_store['I_sc']]))
		cnt += 1

	scores.sort() # sort the scores

	return np.average(scores[:2]) # return average of top 3 docks



if __name__ == "__main__":

	root = './docking/'

	sub_dirs = [x[1] for x in os.walk(root)]
	sub_dirs = sorted(sub_dirs[0])

	print('Found the following loop directories:')
	for sub in sub_dirs:
		print(sub)

	docking_avgs_6_25 = []
	docking_avgs_7_50 = []


	#Analyze docks for pH=6.25
	for folder in sub_dirs:
		try:
			avg_6_25 = read_score_file(root + folder + '/6.25/output_files/score_local_dock.sc')
			docking_avgs_6_25.append(avg_6_25)

			avg_7_50 = read_score_file(root + folder + '/7.50/output_files/score_local_dock.sc')
			docking_avgs_7_50.append(avg_7_50)

		except:
			print('Error reached while reading file... Skipping to next')
			continue

	# for avg in docking_avgs:
	# 	print(avg)
	binwidth = 2
	bins = range(-30, 0 + binwidth, binwidth)

	dist_avg_6 = np.average(docking_avgs_6_25)
	dist_med_6 = np.median(docking_avgs_6_25)
	dist_std_6 = np.std(docking_avgs_6_25)
	
	dist_avg_7 = np.average(docking_avgs_7_50)
	dist_med_7 = np.median(docking_avgs_7_50)
	dist_std_7 = np.std(docking_avgs_7_50)

	print('\npH=6.25 | Descriptive Statistics:')
	print('-='*30)
	print('Average:\t',dist_avg_6)
	print('Median:\t\t',dist_med_6)
	print('Std:\t\t',dist_std_6)

	print('\npH=7.50 | Descriptive Statistics:')
	print('-='*30)
	print('Average:\t',dist_avg_7)
	print('Median:\t\t',dist_med_7)
	print('Std:\t\t',dist_std_7)
	
	# plt.hist(docking_avgs, bins=bins)
	# plt.ylabel('Frequency (cnt)')
	# plt.xlabel('Docking Interface Score (REU)')
	# plt.title('Distribution of Interface Energies Between Fc and FcRn Proteins (n={})'.format(len(docking_avgs)))
	# plt.show()
