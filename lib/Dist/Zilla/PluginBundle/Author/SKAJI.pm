package Dist::Zilla::PluginBundle::Author::SKAJI 0.001;
use 5.14.0;

package Dist::Zilla::Plugin::_StaticInstall {
    use Moose;
    with 'Dist::Zilla::Role::MetaProvider';
    has static_install => (is => 'ro', default => 1);

    sub metadata {
        +{ x_static_install => 0 + shift->static_install };
    }
}
package Dist::Zilla::Plugin::_ReadmeAnyFromPod {
    package Pod::Markdown::_Github {
        use parent 'Pod::Markdown::Github';
        sub syntax { 'perl' }
    }
    use Moose;
    extends 'Dist::Zilla::Plugin::ReadmeAnyFromPod';

    sub get_readme_content {
        my $self = shift;
        return super() unless $self->type eq "markdown";

        my $parser = Pod::Markdown::_Github->new;
        $parser->output_string(\my $content);
        $parser->parse_characters(1);
        $parser->parse_string_document($self->_get_source_pod);
        $content;
    }
}
package Dist::Zilla::Plugin::_NameFromDirectory {
    use Moose;
    use Path::Tiny ();
    with 'Dist::Zilla::Role::NameProvider';

    sub provide_name {
        my $self = shift;
        my $root = $self->zilla->root->absolute;
        my $name = $root->basename =~ s/(?:^(?:perl|perl5|p5)-|[\-\.]pm$)//xr;
        my @try = ( $name, ucfirst($name), "App-$name", "App-" . ucfirst($name) );
        my ($first) = grep { Path::Tiny->new("lib", ($_ =~ s{-}{/}gr) . ".pm" )->exists } @try;
        return $first if $first;
        $self->log_fatal("Couldn't determine NAME from directory; You must specify it in dist.ini");
    }
}

use Moose;
with 'Dist::Zilla::Role::PluginBundle::Easy',
     'Dist::Zilla::Role::PluginBundle::PluginRemover',
     'Dist::Zilla::Role::PluginBundle::Config::Slicer';

use namespace::autoclean;

has installer => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    default => sub { $_[0]->payload->{installer} || 'MakeMaker' },
);

has static_install => (
    is => 'ro',
    isa => 'Bool',
    lazy => 1,
    default => sub { $_[0]->payload->{static_install} // 1 },
);

has travis => (
    is => 'ro',
    isa => 'Bool',
    lazy => 1,
    default => sub { $_[0]->payload->{travis} // 1 },
);

sub build_file {
    my $self = shift;
    $self->installer =~ /MakeMaker/ ? 'Makefile.PL' : 'Build.PL';
}

sub configure {
    my $self = shift;

    my @accepts = qw( MakeMaker ModuleBuild ModuleBuildTiny );
    my %accepts = map { $_ => 1 } @accepts;

    unless ($accepts{$self->installer}) {
        die sprintf("Unknown installer: '%s'. " .
                    "Acceptable values are MakeMaker, ModuleBuild and ModuleBuildTiny\n",
                    $self->installer);
    }

    my @dirty_files = ('dist.ini', 'Changes', 'META.json', 'README.md', $self->build_file);
    my @exclude_release = ('README.md', 'dist.ini');

    $self->add_plugins(
        [ '_NameFromDirectory' ],

        [ '_StaticInstall', { static_install => $self->static_install } ],

        # Make the git repo installable
        [ 'Git::GatherDir', { exclude_filename => [ $self->build_file, 'META.json', 'LICENSE', @exclude_release ] } ],
        [ 'CopyFilesFromBuild', { copy => [ 'META.json', 'LICENSE', $self->build_file ] } ],

        # should be after GatherDir
        # Equivalent to Module::Install's version_from, license_from and author_from
        [ 'VersionFromModule' ],
        [ 'LicenseFromModule', { override_author => 1 } ],

        [ 'ReversionOnRelease', { prompt => 1 } ],

        # after ReversionOnRelease for munge_files, before Git::Commit for after_release
        [ 'NextRelease', { format => '%v  %{yyyy-MM-dd HH:mm:ss VVV}d%{ (TRIAL RELEASE)}T' } ],

        [ 'Git::Check', { allow_dirty => \@dirty_files } ],

        # Make Github center and front
        [ 'GithubMeta', { issues => 1 } ],
        [ '_ReadmeAnyFromPod', { type => 'markdown', filename => 'README.md', location => 'root' } ],

        $self->travis ? [ 'GitHubREADME::Badge', { badges => 'travis' } ] : (),

        # Set no_index to sensible directories
        [ 'MetaNoIndex', { directory => [ qw( t xt inc share eg examples author ) ] } ],

        # cpanfile -> META.json
        [ 'Prereqs::FromCPANfile' ],
        [ $self->installer ],
        [ 'MetaJSON' ],

        # x_contributors for MetaCPAN
        [ 'Git::Contributors' ],

        # standard stuff
        [ 'MetaYAML' ],
        [ 'License' ],
        [ '_ReadmeAnyFromPod', 'ReadmeAnyFromPod/ReadmeTextInBuild' ],
        [ 'ExecDir', { dir => 'script' } ],
        [ 'Manifest' ],
        [ 'ManifestSkip' ],

        [ 'CheckChangesHasContent' ],
        [ 'TestRelease' ],
        [ 'ConfirmRelease' ],
        [ $ENV{FAKE_RELEASE} ? 'FakeRelease' : 'UploadToCPAN' ],

        [ 'CopyFilesFromRelease', { match => '\.pm$' } ],
        [ 'Git::Commit', {
            commit_msg => '%v',
            allow_dirty => \@dirty_files,
            allow_dirty_match => '\.pm$', # .pm files copied back from Release
        } ],
        [ 'Git::Tag', { tag_format => '%v', tag_message => '' } ],
        [ 'Git::Push', { remotes_must_exist => 0 } ],

    );
}

__PACKAGE__->meta->make_immutable;

1;
__END__

=encoding utf-8

=head1 NAME

Dist::Zilla::PluginBundle::Author::SKAJI - BeLike::SKAJI when you build your dists

=head1 SYNOPSIS

  dzil new --provider Author::SKAJI --profile default Your::Module

=head1 DESCRIPTION

Dist::Zilla::PluginBundle::Author::SKAJI is based on L<Dist::Milla>.

=head1 AUTHOR

Shoichi Kaji <skaji@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 Shoichi Kaji <skaji@cpan.org>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
