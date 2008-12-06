
require 'redleaf/graph'
require 'redleaf/archetypes'

class Project
	include Redleaf::Archetypes
	
	include_archetype 'http://usefulinc.com/ns/doap#Project'
	include_archetype 'http://web.resource.org/cc/Work'
end

class License
	include Redleaf::Architypes
	
	include_archetype 'http://web.resource.org/cc/License'
	
	def initialize( uri )
		self.about = URI.new( uri )
	end
end


graph = Redleaf::Graph.new

apache_license = License.new( 'http://www.apache.org/licenses/LICENSE-2.0' )
bsd_license = License.new( 'http://usefulinc.com/doap/licenses/bsd' )

redland = Project.new
redland.homepage = 'http://librdf.org/'
redland.license = apache_license

redleaf = Project.new
redleaf.homepage = 'http://deveiate.org/projects/Redleaf'
redleaf.license = bsd_license

