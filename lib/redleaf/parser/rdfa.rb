#!/usr/bin/env ruby
 
require 'redleaf'
require 'redleaf/parser'

# A parser for RDF/A (http://www.w3.org/TR/rdfa-syntax/)
# 
# == Subversion Id
#
#  $Id$
# 
# == Authors
# 
# * Michael Granger <ged@FaerieMUD.org>
# 
# :include: LICENSE
#
#---
#
# Please see the file LICENSE in the BASE directory for licensing details.
#
class Redleaf::RDFaParser < Redleaf::Parser

	# SVN Revision
	SVNRev = %q$Rev$

	# SVN Id
	SVNId = %q$Id$


	# Use the 'rdfa' Redland parser
	parser_type :rdfa
	
	
	### Parse the specified +content+ in the context of the specified +baseuri+. Overridden to 
	### avoid a segfault in Redland 1.0.8/Raptor 1.4.18:
	###   #0  0x96816e70 in strlen ()
	###   #1  0x0079d5c0 in rdfa_create_context ()
	###   #2  0x00790f52 in raptor_librdfa_parse_start ()
	###   #3  0x003ba644 in librdf_parser_raptor_parse_into_model_common (context=0x143ed90, 
	###         uri=0x0, string=0x1526d00 "something", fh=0x0, length=0, base_uri=0x0, 
	###         model=0x1441280) at rdf_parser_raptor.c:898
	###   #4  0x003ba7a7 in librdf_parser_raptor_parse_string_into_model (context=0x143ed90, 
	###         string=0x1526d00 "something", base_uri=0x0, model=0x1441280) at 
	###         rdf_parser_raptor.c:965
	###   #5  0x003b879d in librdf_parser_parse_string_into_model (parser=0x143ed10, 
	###         string=0x1526d00 "something", base_uri=0x0, model=0x1441280) at rdf_parser.c:495
	###   #6  0x001e54df in rleaf_redleaf_parser_parse (argc=-1, argv=0xffffffff, 
	###         self=18139960) at parser.c:299
	###   #7  0x000d1017 in rb_with_disable_interrupt ()
	###   #8  0x000da14c in rb_eval_string_wrap ()
	###   #9  0x000dad2a in rb_eval_string_wrap ()
	def parse( content, baseuri=nil )
		raise ArgumentError, "the RDFa parser currently requires a baseuri" if baseuri.nil?
		super
	end
	

end # class Redleaf::RDFaParser

# vim: set nosta noet ts=4 sw=4:

