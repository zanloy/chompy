# -*- encoding: utf-8 -*-
# stub: mini_exiftool 2.4.2 ruby lib

Gem::Specification.new do |s|
  s.name = "mini_exiftool"
  s.version = "2.4.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Jan Friedrich"]
  s.date = "2014-05-21"
  s.description = ""
  s.email = "janfri26@gmail.com"
  s.homepage = "http://gitorious.org/mini_exiftool"
  s.licenses = ["LPGLv2"]
  s.post_install_message = "\n+-----------------------------------------------------------------------+\n| Please ensure you have installed exiftool at least version 7.65       |\n| and it's found in your PATH (Try \"exiftool -ver\" on your commandline).|\n| For more details see                                                  |\n| http://www.sno.phy.queensu.ca/~phil/exiftool/install.html             |\n| You need also Ruby 1.9 or higher.                                     |\n| If you need support for Ruby 1.8 or exiftool prior 7.65 install       |\n| mini_exiftool version < 2.0.0.                                        |\n+-----------------------------------------------------------------------+\n  "
  s.rubygems_version = "2.2.2"
  s.summary = "This library is wrapper for the Exiftool command-line application (http://www.sno.phy.queensu.ca/~phil/exiftool)."

  s.installed_by_version = "2.2.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rim>, ["~> 2.4"])
    else
      s.add_dependency(%q<rim>, ["~> 2.4"])
    end
  else
    s.add_dependency(%q<rim>, ["~> 2.4"])
  end
end
