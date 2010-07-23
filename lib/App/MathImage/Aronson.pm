# Copyright 2010 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-Image is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-Image.  If not, see <http://www.gnu.org/licenses/>.

package App::MathImage::Aronson;
use 5.004;
use strict;
use warnings;
# use Lingua::EN::Numbers 1.01 'num2en_ordinal';  # 1.01 rewrite
use Lingua::Any::Numbers 'to_ordinal';

# uncomment this to run the ### lines
#use Smart::Comments;

use vars '$VERSION';
$VERSION = 11;

sub new {
  my $class = shift;
  my $self = bless { upto         => 7,  # less 1 for pos() being after the T
                     queue        => [ ],
                     ret          => [ 1, 4 ], # "T is the" ... first
                     letter       => 't',
                     conjunctions => 0,  # default no "and"s per sloane
                     lang         => 'en',
                     @_
                   }, $class;
  if ($self->{'lang'} eq 'fr') {
    $self->{'letter'} = 'e';
    $self->{'ret'} = [ 1, 2 ]; # "E est la "
    $self->{'upto'} = 7;
  }
  return $self;
}

sub next {
  my ($self) = @_;
  my $ret = $self->{'ret'};
  for (;;) {
    if (my $n = shift @$ret) {
      push @{$self->{'queue'}}, $n;
      return $n;
    }

    my $k = shift @{$self->{'queue'}}
      || return;  # end of sequence

    my $str = to_ordinal($k,$self->{'lang'});
    ### orig str: $str
    if (! $self->{'conjunctions'}) { $str =~ s/\b(and|et)\b//g; }
    $str =~ tr/\x{E8}-\x{EB}/eeee/;
    if ($str eq 'premier') { $str = 'premiere'; }
    $str =~ tr/a-z//cd;
    ### munged str: $str

    my $upto = $self->{'upto'};
    my $letter = $self->{'letter'};
    my $pos = 0;
    while (($pos = index($str,$letter,$pos)) >= 0) {
      push @$ret, $pos++ + $upto;
    }
    $self->{'upto'} += length($str);
    ### now upto: $self->{'upto'}
    ### ret: $ret
    ### queue: $self->{'queue'}
  }
}

1;
__END__

=for stopwords Ryde Aronson Aronson's proven

=head1 NAME

App::MathImage::Aronson -- generate values of Aronson's sequence

=head1 SYNOPSIS

 use App::MathImage::Aronson;
 my $aronson = App::MathImage::Aronson->new;
 print $aronson->next,"\n";
 print $aronson->next,"\n";

=head1 DESCRIPTION

Aronson's sequence is a recurrence generated from positions of the letter T
in numbers expressed in words.

    T is the first, fourth, eleventh, sixteenth, ...
    ^    ^       ^      ^         ^      ^   ^
    1    4      11     16        24     29  33

In the starting "T is the", the letter T is the first and fourth letters, so
those words are added to make "T is the first, fourth".  In those new words
"first, fourth" there are further Ts at 11 and 16, so those words are added,
and so on.

Spaces and punctuation are ignored.  It's possible for the sequence to end,
since the ordinal names for some numbers don't have any Ts in them, but in
English there doesn't seem to be enough of them, or the sequence doesn't
fall on enough of them, to end.  (Is that proven?)

On reaching 104 there's a choice whether to write that as "one hundred and
four" or just "one hundred four".  The default is to include the "and", but
there's an option below to try it without.

=head1 FUNCTIONS

=over

=item C<< $obj = App::MathImage::Aronson->new (key => value, ...) >>

Create and return a new Aronson sequence object.  The following optional
key/value parameters affect the sequence.

=item C<< conjunctions => $boolean >>, default true

Whether to include conjunctions, meaning "and" in the wording.  The default
is to do so.

=item C<< hi => $integer >>, default C<undef>

The highest value desired from the sequence object.

=back

=cut
