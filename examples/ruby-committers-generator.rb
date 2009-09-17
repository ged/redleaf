#!/usr/bin/env ruby
# coding: utf-8

# This is a Redleaf port of Yuki Sonoda's RDF generator for the Ruby committers
# list from here:
# 
#   http://coderepos.org/share/browser/lang/ruby/ruby-committers/rdf-generator.rb
# 
# It requires this file as input:
# 
#   http://homemastar.blogdb.jp/share/browser/lang/ruby/ruby-committers/ruby-committers.yml

BEGIN {
	require 'pathname'
	basedir = Pathname( __FILE__ ).dirname.parent
	libdir = basedir + 'lib'
	extdir = basedir + 'ext'

	$LOAD_PATH.unshift( libdir, extdir )
}

require 'uri'
require 'yaml'

require 'redleaf'
require 'redleaf/constants'

SOCIAL_NETWORK_URIS = [
	'twitter'    => URI('http://twitter.com'),
	'friendfeed' => URI('http://friendfeed.com'),
	'github'     => URI('http://github.com'),
	'facebook'   => URI('http://facebook.com'),
	'mixi'       => URI('http://mixi.jp'),
]

committers = YAML.load_file( 'ruby-committers.yml' )

include Redleaf::Constants::CommonNamespaces # For FOAF and RDF namespaces
graph = Redleaf::Graph.new

committers.each do |attrs|
	account = attrs['account'].to_sym

	graph << [ account, RDF[:type], FOAF[:Person] ]

	attrs['name'].each {|name| graph << [account, FOAF[:name], name] } unless
		attrs['name'].nil?
	attrs['nick'].each {|nick| graph << [account, FOAF[:nick], nick] } unless
		attrs['nick'].nil?
	attrs['portraits'].each {|url| graph << [account, FOAF[:depiction], URI(url)] } unless
		attrs['portraits'].nil?

	attrs['sites'].each do |site|
		if site['feed']
			graph << [ account, FOAF[:weblog], URI(site['url']) ]
		else
			graph << [ account, FOAF[:homepage], URI(site['url']) ]
		end
	end unless attrs['sites'].nil?

	SOCIAL_NETWORK_URIS.each do |service, url|
		if attrs['services'].key?( service )
			# Until Hash-insertion works, you have to insert statements with anonymous
			# blank nodes first to get the correct auto-generated nodeid back. Then you 
			# can use it as the subject for the rest of the statements. Hash-insertion
			# will allow appending complex graphs directly.
			account = Redleaf::Statement.new( account, FOAF[:holdsAccount], :_ )
			graph << account
			graph <<
				[ account.object, RDF[:type], FOAF[:OnlineAccount] ] <<
				[ account.object, FOAF[:accountName], attrs['services'][service] ] <<
				[ account.object, FOAF[:accountServiceHomepage], URI(url) ]
		end
	end unless attrs['services'].nil?

	attrs['ruby-books'].each do |isbn|
		isbn_urn = URI( "urn:isbn:#{isbn}" )
		graph << [account, FOAF[:made], isbn_urn]
	end unless attrs['ruby-books'].nil?
end

puts graph.to_rdfxml_abbrev

# vim: set fileencoding=utf-8
