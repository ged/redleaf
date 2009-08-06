#!/usr/bin/env ruby

# This is an experiment to work out a good way of expanding a node-graph
# expressed as a Turtle-style Hash into a set of triples.

graph = {
	ME => {
		RDF[:type] => FOAF[:Person],  # No equivalent 'a' shortcut yet...
		FOAF[:family_name] => "Granger",
		FOAF[:givenname] => "Michael",
		FOAF[:homepage] => URI('http://deveiate.org/'),
		FOAF[:knows] => [
			{
				RDF[:type] => FOAF[:Person],
				FOAF[:mbox_sha1sum] => "fd2b68f1f42cf523276824cb93261b0de58621b6",
				FOAF[:name] => "Mahlon E Smith",
			},
			{
				RDF[:type] => FOAF[:Person],
				FOAF[:mbox_sha1sum] => "067bff08b083e3a221f72271628af035668f27a6",
				FOAF[:name] => "Chis Chen",
			},
		]
		FOAF[:mbox_sha1sum] => "8680b054d586d747a6fcb7046e9ce7cb39554404",
		FOAF[:name] => "Michael Granger",
		FOAF[:phone] => URI('tel:971.645.5490'),
		FOAF[:workplaceHomepage] => URI('http://laika.com/'),
	},
}


triples = []

def unwrap_object( tuple )
	 
end

def unwrap_subgraph( tuple )
	
	
end

graph.each do |subj, tuple|
	
end

# Cases:
# { s => { p => o } }
# 	[ s, p, o ]
# 
# { s => { p => [o, o1] } }
# 	[ s, p, o ]
# 	[ s, p, o1 ]
# 
# { s => { p => { p1 => o1 } } }
# 	[ s, p, :anon ]
# 	[ :anon, p1, o1 ]
# 
# { s => { p => [{p1 => o1}, {p2 => o2}] } }
# 	[ s, p, :anon1 ]
# 	[ :anon1, p1, o1 ]
# 	[ :anon1, p2, o2 ]
# 
