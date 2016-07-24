package Dist::Zilla::Plugin::Author::SKAJI::FirstBuild;
use 5.14.0;
use Moose;
with 'Dist::Zilla::Role::AfterMint';

use Dist::Zilla::App;
use File::pushd;
use Git::Wrapper;

sub after_mint {
    my ($self, $opts) = @_;

    my $root = "$opts->{mint_root}";
    {
        my $guard = pushd $root;
        for my $cmd (['build', '--no-tgz'], ['clean']) {
            local @ARGV = @$cmd;
            Dist::Zilla::App->run;
        }
    }
    my $git = Git::Wrapper->new($root);
    $git->add($root);
}

1;
