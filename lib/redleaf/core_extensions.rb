#!/usr/bin/env ruby
 
require 'uri'
require 'pathname'

require 'redleaf'

#--
# A module of core class convenience extensions.
# 
module Redleaf # :nodoc:

	### Container for convenience extensions to Arrays so they know how to do 
	### statement-ish things.
	module ArrayExtensions
		
		### Case-comparison -- invert the comparison if +other+ is a Redleaf::Statement.
		def ===( other )
			super unless other.is_a?( Redleaf::Statement )
			return other === self
		end
		
	end
	
	
	### Container for convenience extensions to String for plain literals
	module StringExtensions
		
		# langtag       = (language
	    #                 ["-" script]
	    #                 ["-" region]
	    #                 *("-" variant)
	    #                 *("-" extension)
	    #                 ["-" privateuse])
		LanguageTag = Struct.new( "RedleafLanguageTag",
			:language, :script, :region, :variant, :extensions, :privateuse )


		attr_accessor :language_tag
		
		
		### Set the language tag of the String. This should be a Symbol of the
		### values described by RFC 4646.
		def lang=( language )
			return @language_tag = nil if language.nil?
			parts = language.to_s.downcase.split('-').collect {|s| s.to_sym}
			@language_tag = LanguageTag.new( *parts )
		end
		

		### Get the 'language' part of the language tag of the String, if one is defined.
		def lang
			@language_tag = nil unless defined?( @language_tag )
			return @language_tag.language
		end
		
		
		### Returns +true+ if the specified +language+ matches the 'language' part of
		### the String's language tag, if it has one.
		def is_lang?( language )
			return language.to_sym == self.lang
		end
		
	end


	### Container for convenience casting methods that can be added to Kernel
	module KernelExtensions
		def Namespace( uri ) # :doc:
			Redleaf::Namespace.new( uri )
		end
	end

	

	###############
	module_function
	###############

	### Install extensions to core Ruby classes.
	def install_core_extensions
		Redleaf.log.debug "Installing Array extensions"
		Array.instance_eval { include Redleaf::ArrayExtensions }
		Redleaf.log.debug "Installing String extensions"
		String.instance_eval { include Redleaf::StringExtensions }
		Redleaf.log.debug "Installing Kernel extensions"
		Kernel.instance_eval { include Redleaf::KernelExtensions }
	end
	

end # module Redleaf


