require 'redleaf'

g = Redleaf::Graph.new
exstaff = Redleaf::Namespace[ 'http://www.example.org/staffid/' ]
exterms = Redleaf::Namespace[ 'http://www.example.org/terms/' ]

g <<
	[ exstaff["85740"],  exterms[:address   ],  :johnaddress ] <<
	[ :johnaddress,      exterms[:street    ],  "1501 Grant Avenue" ] <<
	[ :johnaddress,      exterms[:city      ],  "Bedford" ] <<
	[ :johnaddress,      exterms[:state     ],  "Massachusetts" ] <<
	[ :johnaddress,      exterms[:postalCode],  "01730" ]

puts "Graph as NTriples:", g.to_ntriples, ''

puts "Address for %s is: %p" % [
	exstaff["85740"],
	g.object( exstaff["85740"], exterms[:address] )
  ]

# Output:
#   Graph as NTriples:
#   _:johnaddress <http://www.example.org/terms/postalCode> "01730" .
#   <http://www.example.org/staffid/85740> <http://www.example.org/terms/address> _:johnaddress .
#   _:johnaddress <http://www.example.org/terms/city> "Bedford" .
#   _:johnaddress <http://www.example.org/terms/street> "1501 Grant Avenue" .
#   _:johnaddress <http://www.example.org/terms/state> "Massachusetts" .
#   
#   Address for http://www.example.org/staffid/85740 is: :johnaddress

