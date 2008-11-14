#!/usr/bin/env ruby

BEGIN {
	require 'pathname'

	basedir = Pathname.new( __FILE__ ).dirname.parent
	
	extdir = basedir + 'ext'
	libdir = basedir + 'lib'
	
	$LOAD_PATH.unshift( extdir.to_s ) unless $LOAD_PATH.include?( extdir.to_s )
	$LOAD_PATH.unshift( libdir.to_s ) unless $LOAD_PATH.include?( libdir.to_s )
}

require 'pp'
require 'open-uri'
require 'set'
require 'logger'

require 'redleaf'
require 'redleaf/constants'
require 'redleaf/graph'
require 'redleaf/store/sqlite'

# Redleaf.logger.level = Logger::DEBUG
Redleaf.install_core_extensions
include Redleaf::Constants::CommonNamespaces

def make_classname( label )
	label.gsub( /(?:\s+|^)(.)/ ) { $1.upcase }
end

store = Redleaf::SQLiteStore.load( 'vocabmixin.db' )
graph = store.graph

if graph.empty?
	$stderr.puts "Loading DOAP vocabulary from #{DOAP}"
	graph.load( DOAP )
else
	$stderr.puts "DOAP vocabulary already loaded."
end

$stderr.puts( graph.to_turtle )


unhandled = []
modules = {}

class RDFModule

	def self::define( graph, subject )
		instance = self.new( subject.fragment )
		
		graph[ subject, nil, nil ].each do |stmt|
			case stmt.predicate
			when RDFS[:comment]
				instance.comment = stmt.object if stmt.object.lang == 'EN'
			else
				$stderr.puts "Unhandled predicate %s for class %s" % [ stmt.predicate, subject ]
			end
		end
		
		return instance
	end

	def initialize( name )
		@name         = name
		@superclasses = []
		@properties   = []
		@label        = nil
		@comment      = nil
	end
	
	attr_accessor :name, :superclasses, :comment, :label, :properties
	
	
	def to_s
		return %{[%s < %p: %s "%s" (%p)]"} % [ name, superclasses, label, comment, properties ]
	end
	
end


graph.each do |stmt|
	subject = stmt.subject
	typenode = graph[ subject, RDF[:type], nil ].first
	
	case typenode.object
	when RDFS[:Class]
		modname = subject.fragment
		modules[ modname ] = RDFModule.define( graph, subject )

	when RDF[:Property]
		$stderr.puts "Would add a %s property" % [ stmt.subject.fragment ]
		
	else
		unhandled << subject
	end
end

$stderr.puts "Defined modules:",
	modules.collect {|modname,moddef| "  %s %s" % [modname, moddef] }

$stderr.puts "Unhandled subjects:",
	unhandled.to_a.collect {|stmt| "  #{stmt}" }.sort

