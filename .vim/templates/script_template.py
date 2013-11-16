#!/usr/bin/python

import time # for timing
import numpy # for sci comp
import matplotlib
matplotlib.use('Agg') # don't use X
import matplotlib.pylab as plt # for plotting
from matplotlib.backends.backend_pdf import PdfPages # for exporting to pdf
#import commands # print commands.getoutput(script)

# Set up logging
import logging
logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')

def read_file(file_name):
	"""reads in a file and prints each line
	"""
	file_contents = []
	file_in = open(file_name, 'r')
	for line in file_in:
		logging.debug("read: %s" % line[:-1]) # strip off the \n
		file_contents.append(line)
	file_in.close()
	return file_contents

def write_file(file_name, output):
	"""Writes contents of output to file_name
	"""
	file_out = open(file_name, 'w')
	for output_line in output:
		logging.debug("write: %s" % str(output_line))
		file_out.write("%s\n" % str(output_line))
	file_out.close()

def plot_heat_map(
		x_values,
		y_values,
		z_values,
		fig=None,
		subplot_pos=111,
		extra_lines=None,
		xlabel="x_values",
		ylabel="y_values",
		title="The Title"
		save_figure=False,
		figure_path=False,
		):
	"""Plots a heat map (matplotlib.hexplot) in <fig> (or a new figure) at position <subplot_pos>

	extra_lines is an array of elements of the form:
		extra_line = {'x_values': [...], 'y_values': [...], 'color_type': 'r--'}

	if save_figure is False the fig is returned, otherwise it is displayed or saved to figure_path
	"""
	# Make the figure
	if not fig:
		fig = plt.figure()
	ax = fig.add_subplot(subplot_pos)

	# Plot
	X, Y = numpy.meshgrid(x_values, y_values)
	x = X.ravel()
	y = Y.ravel()
	x = x_values.T.ravel()
	plt.hexbin(x, y, C=z, gridsize=30)
	plt.colorbar()

	if extra_lines:
		for extra_line in extra_lines:
			plt.plot(extra_line['x_values'], extra_line['y_values'], extra_line['color_type'])

	# Make it pretty
	ax.set_xlim(numpy.min(x_values), numpy.max(x_values))
	ax.set_xlabel(xlabel)
	ax.set_ylim(numpy.min(y_values), numpy.max(y_values))
	ax.set_ylabel(ylabel)
	ax.set_title(title)
	
	logging.debug("Figure generated.")

	# Save it or return it
	if save_figure:
		if not figure_path:
			return fig
		else:
			plt.savefig(figure_path, bbox_inches=0)
	else:
		plt.show()

def plot_contour(
		x_values,
		y_values,
		z_values,
		fig=None,
		subplot_pos=111,
		extra_lines=None,
		xlabel="x_values",
		ylabel="y_values",
		title="The Title"
		save_figure=False,
		figure_path=False,
		):
	"""Plots a contour plot (matplotlib.contour) in <fig> (or a new figure) at position <subplot_pos>

	extra_lines is an array of elements of the form:
		extra_line = {'x_values': [...], 'y_values': [...], 'color_type': 'r--'}

	if save_figure is False the fig is returned, otherwise it is displayed or saved to figure_path
	"""
	# Make the figure
	if not fig:
		fig = plt.figure()
	ax = fig.add_subplot(subplot_pos)

	# Plot
	X, Y = numpy.meshgrid(x_values, y_values)
	plt.contour(X, Y, z_values, 100) # 100 contour lines

	if extra_lines:
		for extra_line in extra_lines:
			plt.plot(extra_line['x_values'], extra_line['y_values'], extra_line['color_type'])

	# Make it pretty
	ax.set_xlim(numpy.min(x_values), numpy.max(x_values))
	ax.set_xlabel(xlabel)
	ax.set_ylim(numpy.min(y_values), numpy.max(y_values))
	ax.set_ylabel(ylabel)
	ax.set_title(title)
	
	logging.debug("Figure generated.")

	# Save it or return it
	if save_figure:
		if not figure_path:
			return fig
		else:
			plt.savefig(figure_path, bbox_inches=0)
	else:
		plt.show()

def plot_line(
		x_values,
		y_values,
		fig=None,
		subplot_pos=111,
		extra_lines=None,
		xlabel="x_values",
		ylabel="y_values",
		title="The Title"
		save_figure=False,
		figure_path=False,
		):
	"""Plots a line and saves it to file

	extra_lines is an array of elements of the form:
		extra_line = {'x_values': [...], 'y_values': [...], 'color_type': 'r--'}

	if save_figure is False the fig is returned, otherwise it is displayed or saved to figure_path
	"""
	# Make the figure
	if not fig:
		fig = plt.figure()
	ax = fig.add_subplot(subplot_pos)

	# Plot
	ax.plot(x_values, y_values)

	# Make it pretty
	ax.set_xlim(numpy.min(x_values), numpy.max(x_values))
	ax.set_xlabel(xlabel)
	ax.set_ylim(numpy.min(y_values), numpy.max(y_values))
	ax.set_ylabel(ylabel)
	ax.set_title(title)
	
	logging.debug("Figure generated.")

	# Save it or return it
	if save_figure:
		if not figure_path:
			return fig
		else:
			plt.savefig(figure_path, bbox_inches=0)
	else:
		plt.show()

def main():
	starting_time = time.time()

	# FILE I/O
	# read_file(file_name)
	# write_file(file_name, output)

	# PLOTTING
	# pdf_stream = PdfPages("output.pdf")
	# fig = plot_line(x_values, y_values, save_figure=True)
	# pdf_stream.savefig()
	# fig = plot_contour(x_values, y_values, z_values, save_figure=True)
	# pdf_stream.savefig()
	# pdf_stream.close()

	ending_time = time.time()
	logging.debug("Total time in script: %f" % (ending_time - starting_time))

if __name__ == '__main__':
	main()
