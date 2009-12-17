#!/usr/bin/env ruby

# Experimental 'GraphPath' (http://www.langdale.com.au/GraphPath/) implementation for
# Redleaf

BEGIN {
	require 'rbconfig'
	require 'pathname'
	basedir = Pathname.new( __FILE__ ).dirname.parent.expand_path
	libdir = basedir + "lib"
	extdir = libdir + Config::CONFIG['sitearch']

	puts ">>> Adding #{libdir} to load path..."
	$LOAD_PATH.unshift( libdir.to_s )

	puts ">>> Adding #{extdir} to load path..."
	$LOAD_PATH.unshift( extdir.to_s )
}

BASEDIR = Pathname.new( __FILE__ ).dirname.parent
FOAFDATA = BASEDIR + 'spec/data/mgranger-foaf.xml'

require 'rubygems'
require 'redleaf'
require 'logger'

Redleaf.logger.level = Logger::DEBUG

module Redleaf::GraphPath

	class StrategyError < NotImplementedError
		MSG = "expression cannot be evaluated in the given contact (or no context provided)"
		def initialize( step )
			@expr = step
			super( MSG )
		end

		def to_str
			return "%s: %s" % [ super, @expr ]
		end
	end

	class Step
		def initialize
			@tracer = nil
		end

		def match( population, values )
			raise StrategyError, self
		end
		def match( population, subjects )
			raise StrategyError, self
		end
		def terminals( population )
			raise StrategyError, self
		end
		def initials( population )
			raise StrategyError, self
		end
		def filter_initials( population, sequence )
			predicate = self.initials( population )
			sequence.each do |node|
				yield( node ) if predicate.include?( node )
			end
		end
		def filter_terminals( population, sequence )
			predicate = self.terminals( population )
			sequence.each do |node|
				yield( node ) if predicate.include?( node )
			end
		end

		def /( other )
			return Path.new( self, other )
		end

		# def __floordiv__( other):
		# 	"""Transitive path traversal operator."""
		# 	return Closure( other)

		def %( other )
			return Projection.new( self, other )
		end

		def []( other )
			return Predicate.new( self, other )
		end

		def &( other )
			return Intersect.new( self, other )
		end

		def |( other )
			return Union.new( self, other )
		end

		def ~
			return InverseOf.new( self )
		end

		def >>( population )
			return BoundPath.new( population, self )
		end

		# def __rlshift__( population):
		# 	"""Evaluation operator.
		# 
		# 	Note: experimental and subject to removal.
		# 	"""
		# 	for result in self.terminals( population ):
		# 		return result
		# 	else:
		# 		raise ValueError, "path yields empty set"

		def each( &block )
			self.terminals.each( &block )
		end

		def trace
			@tracer = Proc.new
		end

		#########
		protected
		#########

		def chain( s1, s2 )
			return lambda {|&block|
				s1.each( &block )
				s2.each( &block )
			}
		end
	end

	module SingletonBehavior
		def ==( other )
			return self.class == other.class
		end
		def inspect
			return "%p()" % [ self.class ]
		end
	end

	module UnaryBehavior
		def initialize( arg )
			@arg = arg
		end

		attr_accessor :arg

		def ==( other )
			return self.class == other.class &&
				self.arg == other.arg
		end

		def inspect
			return "%p( %p )" % [ self.class, self.arg ]
		end
	end

	module BinaryBehavior
		def initialize( lhs, rhs )
			@lhs = lhs
			@rhs = rhs
		end

		attr_accessor :lhs, :rhs

		def ==( other )
			return self.class == other.class &&
				self.lhs == other.lhs &&
				self.rhs == other.rhs
		end

		def inspect
			return "%p( %p, %p )" % [ self.class, self.lhs, self.rhs ]
		end
	end

	class UnaryOp < Step
		include UnaryBehavior

		def trace( &tracer )
			self.arg.trace( &tracer )
			return tracer[ self.class.new(self.arg) ]
		end
	end

	class BinaryOp < Step
		include BinaryBehavior

		def trace( &tracer )
			self.lhs.trace( &tracer )
			self.rhs.trace( &tracer )
			return tracer[ self.class.new(self.lhs, self.rhs) ]
		end
	end

	# Implements the path operator: a/b
	class Path < BinaryOp
		def match( population, values )
			return self.lhs.match( population, self.rhs.match(population, values) )
		end
		def values( population, subjects )
			return self.rhs.values( population, self.lhs.values(population, subjects) )
		end
		def initials( population )
			return self.lhs.match( population, self.rhs.initials(population) )
		end
		def terminals( population )
			return self.rhs.values( population, self.lhs.terminals(population) )
		end
		def filter_initials( population, subjects )
			subjects.each do |subject|
				values = self.lhs.values( population, Set([subject]) )
				yield self.rhs.filter_initials( population, values ).first
			end
		end

		def filter_terminals( population, values )
			values.each do |value|
				subjects = self.rhs.match( population, Set([value]) )
				yield self.rhs.filter_terminals( population, subjects ).first
		end

		def inspect
			return "%p/%p" % [ self.lhs, self.rhs ]
		end

		def invert
			return ~(self.rhs) / ~(self.lhs)
		end
	end # class Path


	# Implements the predicate operator: a[b].
	# 
	# Predicate evaluation requires the initial nodes of the rhs matches
	# to be found.  In each method, the initials are sought explicitly
	# first via initials() then implicitly via filter_initials(). The
	# initials() method is likely to be more efficient when available.
	# 
	# But the initials() method is liable to fail if the predicate consists
	# of an (1) ArcStep or (2) a Path whose rhs is an ArcStep or (3) a
	# Path with a lhs not supporting match() or bound to a context not
	# supporting match() i.e. no inverse property traversal.
	class Predicate < BinaryOp
		def match( population, values )
			initials = filtered = nil

			begin
				initials = self.rhs.initials( population )
			rescue StrategyError
				filtered = Set( self.rhs.filter_initials(population, values) )
			else
				filtered = values & initials
			end

			return self.lhs.match( population, filtered )
		end

		def values( population, subjects )
			terminals = self.lhs.values( population, subjects )
			initials = nil

			begin
				initials = self.rhs.initials( population )
			rescue StrategyError
				return Set( self.rhs.filter_initials(population, terminals) )
			else
				return terminals & initials
			end
		end

		def terminals( population )
			terminals = initials = nil

			begin
				terminals = self.lhs.terminals( population )
			rescue StrategyError
				begin
					initials = self.rhs.initials( population )
				rescue StrategyError
					return Set(
						self.rhs.filter_initials(population, self.lhs.filter_terminals( population, population ))
					  )
				else
					return Set( self.lhs.filter_terminals(population, initials) )
			else
				begin
					initials = self.rhs.initials( population )
				rescue StrategyError
					return Set( self.rhs.filter_initials(population, terminals) )
				else
					return terminals & initials
				end
			end
		end

		def initials( population )
			initials = nil

			begin
				initials = self.rhs.initials( population )
			rescue StrategyError
				initials = Set( self.rhs.filter_initials(population, population) )
			end
			return self.lhs.match( population, initials )
		end

		def inspect
			return "%r[%r]" % [ self.lhs, self.rhs ]
		end

		def invert
			return Self.new[ self.rhs ] / ~(self.lhs)
		end
	end # class Predicate


	# Implements the union operator: a|b
	class Union < BinaryOp
		def match( population, values )
			return self.rhs.match(population, values) | self.lhs.match(population, values)
		end
		def values( population, values )
			return self.lhs.values(population, values) | self.rhs.values(population, values)
		end
		def terminals( population )
			return self.lhs.terminals(population) | self.rhs.terminals(population)
		end
		def initials(self, population):
			return self.lhs.initials(population) | self.rhs.initials(population)
		end
		def filter_initials( population, subjects )
			return chain(
				self.lhs.filter_initials(population, subjects),
					self.rhs.filter_initials(population, subjects) )
				end
		def filter_terminals( population, values )
			return chain( self.lhs.filter_terminals( population, values),
					self.rhs.filter_terminals( population, values))
				end
		def __repr__(self):
			return "(%r|%r)" % (self.lhs, self.rhs)
		end
		def __invert__(self):
			return ~self.rhs | ~self.lhs
		end
	end

	class Node < Step; end
	class Property < Step; end
	class Nodes < Step; end
	class Class < Step; end
	class Subject < Step; end
	class Self < Step; end
	Any = Self

	class HasNo < Step; end

end

g = Redleaf::Graph.new
g.load( FOAFDATA )

