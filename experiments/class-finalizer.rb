#!/usr/bin/env ruby

# This is an experiment to see if you can set a finalizer for a Class object. This might be useful
# for knowing when it's safe to call librdf_free_world().

puts "Defining MyModule"
module MyModule
end

puts "Defining MyModule::MyClass"
class MyModule::MyClass
end

puts "Setting up finalizer for MyModule"
ObjectSpace.define_finalizer( MyModule ) { puts "Finalizing MyModule" }

puts "Setting up finalizer for MyModule::MyClass"
ObjectSpace.define_finalizer( MyModule::MyClass ) { puts "Finalizing MyModule::MyClass" }
puts "done. Exiting."


# Output:
#    
#    $ ruby -v experiments/class-finalizer.rb 
#    ruby 1.8.6 (2008-03-03 patchlevel 114) [universal-darwin9.0]
#    Defining MyModule
#    Defining MyModule::MyClass
#    Setting up finalizer for MyModule
#    Setting up finalizer for MyModule::MyClass
#    done. Exiting.
#    Finalizing MyModule::MyClass
#    Finalizing MyModule
#    
