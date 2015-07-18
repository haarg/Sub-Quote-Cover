package Sub::Quote::Cover;
use strict;
use warnings;
use Sub::Quote;
use File::Spec;

our $VERSION = '0.001000';
$VERSION =~ tr/_//d;

my $_clean_eval = \&Sub::Quote::_clean_eval;

my $cover_db;
my $all_code = '';
my $evals = 0;

sub _eval {
  my $code = $_[0];
  $evals++;

  if (length $all_code) {
    $all_code .= "\n\n" . ('#' x 78) . "\n";
  }
  my $header = "###### Sub::Quote eval $evals ";
  $header .= "#" x (78 - length $header) . "\n";
  $all_code .= $header;

  my $start_line = $all_code =~ tr/\n// + 1;
  $all_code .= $code;

  my $file = File::Spec->catfile($cover_db, "Sub-Quote-evals-$$");
  open my $fh, '>', $file
    or die "Can't create $file: $!";
  print { $fh } $all_code;
  close $fh;

  $_clean_eval->("#line $start_line $file\n$code");
}

sub import {
  if ($INC{'Devel/Cover.pm'}) {
    $cover_db = File::Spec->rel2abs('cover_db');
    mkdir $cover_db;
    *Sub::Quote::_clean_eval = \&_eval;
  }
}

1;
__END__

=head1 NAME

Sub::Quote::Cover - Generate full coverage data for L<Sub::Quote> subs

=head1 SYNOPSIS

  cover -delete
  HARNESS_PERL_SWITCHES='-MDevel::Cover -MSub::Quote::Cover' make test
  cover

=head1 DESCRIPTION

This module adjusts the behavior of L<Sub::Quote> to enable L<Devel::Cover> to
show coverage details for all of the generated subs.  This is done by generating
temporary files for L<Devel::Cover> to show reports for.

=head1 CAVEATS

=over 4

=item *

This module monkey patches L<Sub::Quote> to work, which could break in the
future if its internals change.

=item *

This module assumes the coverage database is located at F<./cover_db/>.  If a
different directory is used, this module may behave unexpectedly.

=back

=head1 AUTHOR

haarg - Graham Knop (cpan:HAARG) <haarg@haarg.org>

=head1 CONTRIBUTORS

None yet.

=head1 COPYRIGHT

Copyright (c) 2015 the Sub::Quote::Cover L</AUTHOR> and L</CONTRIBUTORS>
as listed above.

=head1 LICENSE

This library is free software and may be distributed under the same terms
as perl itself. See L<http://dev.perl.org/licenses/>.

=cut
