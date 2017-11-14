require 'rake/clean'

EXT_CONF = 'ext/extconf.rb'
MAKEFILE = 'ext/Makefile'
MODULE = 'ext/HammerUtil.so'
SRC = Dir.glob('ext/*.c')
SRC << MAKEFILE

CLEAN.include [ 'ext/*.o', 'ext/depend', MODULE ]
CLOBBER.include [ 'config.save', 'ext/mkmf.log', MAKEFILE ]

file MAKEFILE => EXT_CONF do |t|
    Dir::chdir(File::dirname(EXT_CONF)) do
        unless sh "ruby #{File::basename(EXT_CONF)}"
            $stderr.puts "Failed to run extconf"
            break
        end
    end
end
file MODULE => SRC do |t|
    Dir::chdir(File::dirname(EXT_CONF)) do
        unless sh "make"
            $stderr.puts "make failed"
            break
        end
    end
end
desc "Build the native library"
task :build => MODULE

=begin
require 'rdoc/task'

RDOC_FILES = FileList["README.rdoc", "ext/my_test.c"]

Rake::RDocTask.new do |rd|
    rd.main = "README.rdoc"
    rd.rdoc_dir = "doc/site/api"
    rd.rdoc_files.include(RDOC_FILES)
end

Rake::RDocTask.new(:ri) do |rd|
    rd.main = "README.rdoc"
    rd.rdoc_dir = "doc/ri"
    rd.generator = "ri"
    rd.rdoc_files.include(RDOC_FILES)
end
=end
