package Dist::Zilla::Plugin::Author::SKAJI::MintFiles;
use 5.14.0;
use Moose;

extends 'Dist::Zilla::Plugin::InlineFiles';
with 'Dist::Zilla::Role::TextTemplate';

has xs => (
    is => 'ro',
    isa => 'Bool',
    lazy => 1,
    default => 0,
);

override 'merged_section_data' => sub {
    my $self = shift;

    my $data = super;

    my $xs         = delete $data->{'Module.xs'};
    my $xs_ini     = delete $data->{'dist.xs.ini'};
    my $xs_builder = delete $data->{'inc/MyBuilder.pm'};
    if ($self->xs) {
        my $path = $self->zilla->name =~ s{-}{/}gr;
        $data->{"lib/$path.xs"    } = $xs;
        $data->{"dist.ini"        } = $xs_ini;
        $data->{"inc/MyBuilder.pm"} = $xs_builder;
        require Devel::PPPort;
        require File::Basename;
        my $dir = "lib/$path";
        $dir = File::Basename::dirname($dir);
        my $ppport = Devel::PPPort::GetFileContents();
        $data->{ "$dir/ppport.h" } = \$ppport;
    }

    for my $name ((), keys %$data) {
        next if $name =~ /\bppport\.h$/;
        $data->{$name} = \$self->fill_in_string(
            ${ $data->{$name} }, {
                dist => \($self->zilla),
                plugin => \($self),
            },
        );
    }

    return $data;
};

1;

__DATA__

__[ dist.ini ]__
[@Author::SKAJI]
__[ dist.xs.ini ]__
[@Author::SKAJI]
static_install = 0
installer = ModuleBuild
ModuleBuild.mb_class = MyBuilder
__[ Changes ]__
Revision history for {{ $dist->name }}

{{ '{{$NEXT}}' }}
    - Initial release
__[ .gitignore ]__
/{{ $dist->name }}-*
/.build
/_build*
/Build
MYMETA.*
!META.json
/.prove
/.carmel/
/MANIFEST
/META.yml
/Makefile
/Makefile.old
/blib/
/cpanfile.snapshot
/local/
/pm_to_blib
*.o
*.c
__[ cpanfile ]__
requires 'perl', '5.8.1';
__[ t/00_use.t ]__
use strict;
use warnings;
use Test::More tests => 1;
use {{ $dist->name =~ s/-/::/gr }};
pass "happy hacking!";
__[ xt/01_basic.t ]__
use strict;
use warnings;
use Test::More;
use {{ $dist->name =~ s/-/::/gr }};

ok "replace me";

done_testing;
__[ .travis.yml ]__
language: perl
sudo: false
perl:
  - "5.22"
  - "5.20"
  - "5.18"
  - "5.16"
  - "5.14"
  - "5.12"
  - "5.10"
  - "5.8"
install:
  - cpanm -nq --installdeps --with-develop .
script:
  - prove -l t/ xt/
__[ Module.xs ]__
#ifdef __cplusplus
extern "C" {
#endif

#define PERL_NO_GET_CONTEXT /* we want efficiency */
#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>

#ifdef __cplusplus
} /* extern "C" */
#endif

#define NEED_newSVpvn_flags
#include "ppport.h"

MODULE = {{$dist->name =~ s/-/::/gr}}  PACKAGE = {{$dist->name =~ s/-/::/gr}}

PROTOTYPES: DISABLE

void
hello()
CODE:
{
  SV* const hello = sv_2mortal(newSVpv("hello", 5));
  XPUSHs(hello);
  XSRETURN(1);
}
__[ inc/MyBuilder.pm ]__
package MyBuilder;
use strict;
use warnings;
use base 'Module::Build';

sub new {
    my $class = shift;
    $class->SUPER::new(
        # c_source => [],
        # include_dirs => [],
        # extra_compiler_flags => [], # -xc++ for c++
        # extra_linker_flags => [],   # -lstdc++ for c++
        @_,
    );
}

1;
