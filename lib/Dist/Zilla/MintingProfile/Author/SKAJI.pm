package Dist::Zilla::MintingProfile::Author::SKAJI;
use 5.14.0;
use Moose;
with 'Dist::Zilla::Role::MintingProfile';

use File::ShareDir::ProjectDistDir qw(dist_dir);
use Path::Tiny ();

sub profile_dir {
    my ($self, $profile_name) = @_;
    my $dir = dist_dir("Dist-Zilla-PluginBundle-Author-SKAJI");
    return Path::Tiny->new($dir)->child($profile_name);
}

1;
