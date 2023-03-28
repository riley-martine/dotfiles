#!/usr/bin/env perl

=pod

=head1 toc.pl

Generates a table of contents for a markdown file, based on the headers present
in the document.

=head2 Usage
C<toc.pl ~/dev/re-documentation/pact/admin/broker.md>

    ## Table of Contents

    - [Interactions With The Broker](#interactions-with-the-broker)
    - [Spinning Up The Broker](#spinning-up-the-broker)
      - [Set up Postgres Secrets](#set-up-postgres-secrets)
        - [Changing the Postgres Secret](#changing-the-postgres-secret)
      - [Set up Pact Broker Write User Secret](#set-up-pact-broker-write-user-secret)
      - [Adding the HelmRelease to the Environment](#adding-the-helmrelease-to-the-environment)
      - [Creating Pact Environments](#creating-pact-environments)

=head2 Requirements

=over

=item perl          (C<brew install perl>)
=item Markdown::TOC (C<cpan -i Markdown::TOC>)
=item Path::Tiny    (C<cpan -i Path::Tiny>)

=back

=head2 Tips

You can also map this in your `.vimrc`: `command! TOC r!toc.pl "%:p"`. This
allows you to call `:TOC`, which will generate a table of contents and paste it
at the cursor's location.

=cut

use strict;
use warnings;
use Markdown::TOC;
use Path::Tiny;
use autodie;    # die if problem reading or writing a file

if ( $#ARGV != 0 ) {
    die "Usage: toc.pl <filename>";
}
my $file    = path( $ARGV[0] );
my $content = $file->slurp_utf8();

my $toc = Markdown::TOC->new(
    handler => sub {
        my %params = @_;
        if ( $params{level} eq 1 ) {
            return '';
        }
        my $indent = '  ' x ( $params{level} - 2 );
        return $indent . '- [' . $params{text} . '](#' . $params{anchor} . ')';
    },
    anchor_handler => sub {
        my ( $text, $level ) = @_;
        my $anchor = $text;
        $anchor =~ s/\s+/-/g;
        return lc($anchor);
    },
    delimeter => "\n"
);

my $toc_text = $toc->process($content);
$toc_text =~ s/^\n//d;
print "## Table of Contents\n\n";
print $toc_text;
print "\n\n";
