require 'redleaf'

g = Redleaf::Graph.new
exstaff = Redleaf::Namespace[ 'http://www.example.org/staffid/' ]
exterms = Redleaf::Namespace[ 'http://www.example.org/terms/' ]

g << {
	exstaff["85740"] => {
		exterms[:address] => {
			exterms[:street] => "1501 Grant Avenue",
			exterms[:city]   => "Bedford",
			exterms[:state]  => "Massachusetts",
			exterms[:postalCode] => "01730",
		}
	}
}

puts "Graph as NTriples:", g.to_turtle, ''

puts "Address for %s is: %p" % [
	exstaff["85740"],
	g.object( exstaff["85740"], exterms[:address] )
  ]

