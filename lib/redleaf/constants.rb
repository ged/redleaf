#!/usr/bin/env ruby
 
begin
	require 'redleaf'
	require 'redleaf/namespace'
rescue LoadError => err
	unless Object.const_defined?( :Gem )
		require 'rubygems'
		retry
	end
	raise
end


# A module of library-wide constants
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
module Redleaf::Constants

	# SVN Revision
	SVNRev = %q$Rev$

	# SVN Id
	SVNId = %q$Id$


	### A collection of useful RDF namespaces, expressed as Redleaf::NameSpace objects.
	module CommonNamespaces
		
		# The RDF Vocabulary -- This is the RDF Schema for the RDF vocabulary defined 
		# in the RDF namespace.
		RDF        = Redleaf::Namespace.new( 'http://www.w3.org/1999/02/22-rdf-syntax-ns#' )

		# The RDF Schema vocabulary
		RDFS       = Redleaf::Namespace.new( 'http://www.w3.org/2000/01/rdf-schema#' )
		
		# DCMI Namespace for the Dublin Core Metadata Element Set, Version 1.1
		DC         = Redleaf::Namespace.new( 'http://purl.org/dc/elements/1.1/' )

		# DCMI Namespace for metadata terms in the http://purl.org/dc/terms/ namespace
		DC_TERMS   = Redleaf::Namespace.new( 'http://purl.org/dc/terms/' )
		
		# DCMI Namespace for metadata terms of the DCMI Type Vocabulary
		DCMI_TYPES = Redleaf::Namespace.new( 'http://purl.org/dc/dcmitype/' )

		# The built-in classes and properties that together form the basis of
		# the RDF/XML syntax of OWL Full, OWL DL and OWL Lite.
		OWL        = Redleaf::Namespace.new( 'http://www.w3.org/2002/07/owl#' )

		# The XML Schema namespace
		XSD        = Redleaf::Namespace.new( 'http://www.w3.org/2001/XMLSchema#' )
		
	end # module CommonNamespaces

end # class Redleaf::Constants


