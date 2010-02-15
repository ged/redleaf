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
	
end # class Redleaf::FileStore

# vim: set nosta noet ts=4 sw=4:

