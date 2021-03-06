#!/usr/bin/env rake

require 'rbconfig'
require 'pathname'

begin
	require 'rake/extensiontask'
rescue LoadError
	abort "This Rakefile requires rake-compiler (gem install rake-compiler)"
end

begin
	require 'hoe'
rescue LoadError
	abort "This Rakefile requires hoe (gem install hoe)"
end

BASEDIR          = Pathname( __FILE__ ).dirname
SPECDIR          = BASEDIR + 'spec'
EXTDIR           = BASEDIR + 'ext'

SPEC_DATADIR     = SPECDIR + 'data'
SPEC_TEMPLATEDIR = SPECDIR + 'templates'

W3CTEST_TASKLIB  = SPECDIR + 'w3ctest-tasks.rb'
RDFATEST_TASKLIB = SPECDIR + 'rdfatest-tasks.rb'

# Load the W3C test rake tasks
$stderr.puts "Adding tasks from #{W3CTEST_TASKLIB}" if Rake.application.options.trace
load W3CTEST_TASKLIB
$stderr.puts "Adding tasks from #{RDFATEST_TASKLIB}" if Rake.application.options.trace
load RDFATEST_TASKLIB

# Hoe plugins
Hoe.plugin :mercurial
Hoe.plugin :yard
Hoe.plugin :signing
Hoe.plugin :manualgen

Hoe.plugins.delete :rubyforge

# Main hoespec
hoespec = Hoe.spec 'redleaf' do
	self.readme_file = 'README.rdoc'
	self.history_file = 'History.rdoc'
	self.extra_rdoc_files = Rake::FileList[ '*.rdoc' ]

	self.developer 'Michael Granger', 'ged@FaerieMUD.org'

	self.dependency 'rake-compiler', '~> 0.7', :dev
	self.dependency 'rspec', '~> 2.7', :dev

	self.spec_extras[:licenses] = ["BSD"]
	self.spec_extras[:extensions] = [ EXTDIR + 'extconf.rb' ]

	self.require_ruby_version( '>=1.8.7' )
	self.hg_sign_tags = true if self.respond_to?( :hg_sign_tags= )
	self.rdoc_locations << "deveiate:/usr/local/www/public/code/#{remote_rdoc_dir}"
end

ENV['VERSION'] ||= hoespec.spec.version.to_s

# Ensure the specs pass before checking in
task 'hg:precheckin' => :spec

# Support for 'rvm specs'
task :specs => :spec

# Compile before testing
task :spec => :compile
namespace :spec do
    task :doc   => [ :compile ]
    task :quiet => [ :compile ]
    task :html  => [ :compile ]
    task :text  => [ :compile ]
end

desc "Turn on warnings and debugging in the build."
task :maint do
	ENV['MAINTAINER_MODE'] = 'yes'
end

# Rake-compiler task
Rake::ExtensionTask.new do |ext|
	ext.name           = 'redleaf_ext'
	ext.gem_spec       = hoespec.spec
	ext.ext_dir        = 'ext'
	ext.lib_dir        = "lib/#{Config::CONFIG['sitearch']}"
	ext.source_pattern = "*.{c,h}"
	ext.cross_compile  = true
	ext.cross_platform = %w[i386-mswin32 i386-mingw32]
end


### Generated specs (W3C and RDFa)
desc "Build the W3C conformance test suite"
task :build_specs => 'w3ctests:generate'

desc "Build the W3C RDFa test suite"
task :build_specs => 'rdfatests:generate'


#####################################################################
###	T A S K S
#####################################################################

# Add a target for running the specs under GDB for debugging
namespace :spec do

	desc "Run specs under gdb"
	task :gdb => [ :compile ] do |task|
		require 'tempfile'

		cmd_parts = ['run']
		cmd_parts << '-Ilib:ext'
		cmd_parts << '/usr/bin/spec'
		cmd_parts += SPEC_FILES.collect { |fn| %["#{fn}"] }
		cmd_parts += COMMON_SPEC_OPTS + ['-f', 's', '-c']

		script = Tempfile.new( 'spec-gdbscript' )
		script.puts( cmd_parts.join(' ') )
		script.flush

		run 'gdb', '-x', script.path, RUBY
	end
end



