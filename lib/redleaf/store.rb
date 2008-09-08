#!/usr/bin/env ruby
 
require 'redleaf'
require 'redleaf/mixins'

# An RDF triplestore abstract base class
# 
# == Subversion Id
#
#  $Id$
# 
# == Authors
# 
# * Michael Granger <ged@FaerieMUD.org>
# * Mahlon Smith <mahlon@martini.nu>
# 
# :include: LICENSE
#
#---
#
# Please see the file LICENSE in the BASE directory for licensing details.
#
class Redleaf::Store
	include Redleaf::Loggable

	# SVN Revision
	SVNRev = %q$Rev$

	# SVN Id
	SVNId = %q$Id$


	#################################################################
	###	C L A S S   M E T H O D S
	#################################################################

	### Set the class's Redland backend to +new_setting+ if given, and return the current
	### (new) setting.
	def self::backend( new_setting=nil )
		if new_setting
			Redleaf.logger.debug "Setting backend for %p to %p" % [ self, new_setting ]
			@backend = new_setting
		end
		
		return @backend
	end


	### Make a librdf_hash-style optstring from the given +opthash+ and return it.
	def self::make_optstring( opthash )
		return opthash.collect {|k,v| %:%s = '%s': % [k,v] }.join( ',' )
	end
	

end # class Redleaf::Store

# vim: set nosta noet ts=4 sw=4:

