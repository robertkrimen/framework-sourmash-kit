use inc::Module::Install;

name 'Framework-Sourmash-Kit';
all_from 'lib/Framework/Sourmash/Kit.pm';

build_requires 'Test::More';

auto_install;

WriteAll;

