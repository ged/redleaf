#!/usr/bin/env ruby
 
require 'uri'
require 'pathname'

require 'redleaf'


# A module of core class convenience extensions.
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
module Redleaf

	# Add convenience extensions to Arrays so they know how to do statement-ish things.
	module ArrayExtensions
		
		### Case-comparision -- invert the comparison if +other+ is a Redleaf::Statement.
		def ===( other )
			super unless other.is_a?( Redleaf::Statement )
			return other === self
		end
		
	end


	###############
	module_function
	###############

	### Install extensions to core Ruby classes.
	def install_core_extensions
		Redleaf.log.debug "Installing Array extensions"
		Array.instance_eval { include Redleaf::ArrayExtensions }
	end
	

end # module Redleaf


