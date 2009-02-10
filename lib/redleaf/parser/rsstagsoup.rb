#!/usr/bin/env ruby
 
require 'redleaf'
require 'redleaf/parser'

# A parser for the multiple XML RSS formats that use the elements such as
# channel, item, title, description in different ways. This includes support
# for the Atom 1.0 syndication format defined in IETF RFC 4287
#	
# The parser attempts to turn the input into RSS 1.0 RDF triples in the RSS
# 1.0 model of a syndication feed. This includes triples for RSS Enclosures.
#	
# True RSS 1.0 when wanted to be used as a full RDF vocabulary, is best parsed
# by the RDF/XML parser (Redleaf::Parser::RDFXMLParser).
#	
# == Subversion Id
#
#	$Id$
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
class Redleaf::RSSTagSoupParser < Redleaf::Parser

	# SVN Revision
	SVNRev = %q$Rev$

	# SVN Id
	SVNId = %q$Id$


	# Use the 'rss-tag-soup' Redland parser
	parser_type :rss_tag_soup
	

end # class Redleaf::RDFXMLParser

# vim: set nosta noet ts=4 sw=4:

