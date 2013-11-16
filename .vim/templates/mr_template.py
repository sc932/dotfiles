# -*- coding: utf-8 -*-
"""
Calculates ...
"""
from mrjob.job import MRJob


class MRJobName(MRJob):
	"""Docstring...
	"""

	def configure_options(self):
		super(MRJobName, self).configure_options()

		self.add_passthrough_option(
				'--set-true',
				dest='bool_val',
				action='store_true',
				default=False,
				help='Sets self.options.bool_val to True'
				)

		self.add_passthrough_option(
			'--float-opt',
			dest='float_val',
			type='float',
			default=0.0,
			help='Sets self.options.float_val to a value'
		)

	def mapper(self, _, ad_event):
		"""docstring
		"""
		yield key, value

	def reducer(self, key, values):
		"""docstring
		"""
		yield key, values	

if __name__ == "__main__":
	MRJobName.run()
