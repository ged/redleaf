#!/usr/bin/env ruby

require 'redleaf'
require 'redleaf/store'

# An in-memory RDF triplestore that is loaded and saved as a flat file on disk
# 
# == Version-Control Id
#
#  $Id$
# 
# == Authors
# 
# * Michael Granger <ged@FaerieMUD.org>
# 
# :include: LICENSE
#
#--
#
# Please see the file LICENSE in the BASE directory for licensing details.
#
class Redleaf::FileStore < Redleaf::Store


	# Use the 'file' Redland backend
	backend :file


	#################################################################
	###	I N S T A N C E   M E T H O D S
	#################################################################

	### Create a new Redleaf::FileStore that will write RDF/XML to the given +filename+, moving
	### aside any existing file to a backup if it already exists.
	def initialize( filename )
		return super( filename.to_s )
	end


	######
	public
	######

	### Returns +true+ if the Store is persistent (i.e., its hash_type is :bdb).
	def persistent?
		return true
	end


end # class Redleaf::FileStore

# vim: set nosta noet ts=4 sw=4:

