# Copyright 2011, 2012 Kevin Ryde

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

package Math::NumSeq::MathImageReRound;
use 5.004;
use strict;
use POSIX 'ceil';
use List::Util 'max';

use vars '$VERSION','@ISA';
$VERSION = 90;

use Math::NumSeq 7; # v.7 for _is_infinite()
use Math::NumSeq::Base::IterateIth;
@ISA = ('Math::NumSeq::Base::IterateIth',
        'Math::NumSeq');
*_is_infinite = \&Math::NumSeq::_is_infinite;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant description => Math::NumSeq::__('...');
use constant values_min => 1; # at i=1
use constant i_start => 1;
use constant characteristic_increasing => 1;

use constant parameter_info_array =>
  [
   { name    => 'round_count',
     display => Math::NumSeq::__('Round Count'),
     type    => 'integer',
     default => '1',
     minimum => 1,
     # description => Math::NumSeq::__('...'),
   },
  ];

# cf A000959 lucky numbers 1, 3, 7, 9, 13, 15, 21, ... delete multiples of the next remaining
#    A145649 characteristic
#    A050505 complement
#    A007952 sieve+1
#
my @oeis_anum = (undef,
                 'A002491', #  1 Mancala stones ...
                 'A000960', #  2 Flavius Josephus rounding twice
                 # OEIS-Catalogue: A002491
                 # OEIS-Catalogue: A000960 round_count=2
                );
sub oeis_anum {
  my ($self) = @_;
  return $oeis_anum[$self->{'round_count'}];
}

sub ith {
  my ($self, $i) = @_;
  ### ReRound ith(): $i

  if (_is_infinite($i)) {
    return $i;  # don't loop forever if $i is +infinity
  }

  my $round_add = $self->{'round_count'} - 1;
  ### $round_add

  for (my $m = $i-1; $m >= 1; $m--) {
    ### add: (-$i % $m) + $round_add*$m

    $i += (-$i % $m) + $round_add*$m;
  }
  return $i;
}

# 1,3,7,13,19
# 2->2+1=3
# 3->4+2=6->6+1=7
# 4->6+m3=9->10+m2=12->12+m1=13
#
# next = prev + (-prev mod m) + k*m
# next-k*m = prev + (-prev mod m)

sub pred {
  my ($self, $value) = @_;
  ### ReRound pred(): $value

  my $round_count = $self->{'round_count'};
  my $round_add = $self->{'round_count'} - 1;

  if (_is_infinite($value)) {
    return undef;
  }
  if ($value <= 1 || $value != int($value)) {
    return ($value == 1);
  }

  # special case m=1 stepping down to an even number
  if (($value -= $round_add) % 2) {
    return 0;
  }

  my $m = 2;
  while ($value > $m) {
    ### at: "value=$value  m=$m"

    if (($value -= $round_add*$m) <= 0) {
      ### no, negative: $value
      return 0;
    }
    ### subtract to: "value=$value"

    ### rem: "modulus=".($m+1)." rem ".($value%($m+1))
    my $rem;
    if (($rem = ($value % ($m+1))) == $m) {
      ### no, remainder: "rem=$rem  modulus=".($m+1)
      return 0;
    }

    $value -= $rem;
    $m++;
  }

  ### final ...
  ### $value
  ### $m

  return ($value == $m);
}

1;
__END__

=for stopwords Ryde

=head1 NAME

Math::NumSeq::MathImageReRound -- sequence from repeated rounding up

=head1 SYNOPSIS

 use Math::NumSeq::MathImageReRound;
 my $seq = Math::NumSeq::MathImageReRound->new;
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

This is the sequence of values formed by repeatedly rounding up to a
multiple of i-1,i-2,...,2,1.

    1, 2, 4, 6, 10, 12,

For example i=5 is rounded up to a multiple of 4 to give 8, then rounded up
to a multiple of 3 to give 9, then rounded up to a multiple of 2 for value
10 at i=5.

When rounding up if a value is already a suitable multiple then it's
unchanged.  For example i=4 round up to a multiple of 3 to give 6, then
round up to a multiple of 2 is unchanged 6 since it's already a multiple
of 2.

Because the last step rounds up to a multiple of 2 the values are all even.
They're also monotonically increasing and end up approximately

    value ~= i^2 / pi

though there's values both bigger and smaller than this approximation.

=head1 FUNCTIONS

=over 4

=item C<$seq = Math::NumSeq::MathImageReRound-E<gt>new (key=E<gt>value,...)>

Create and return a new sequence object.

=item C<$bool = $seq-E<gt>pred($value)>

Return true if C<$value> is a ReRound value.

=back

=head1 FORMULAS

=head2 Predicate

The rounding procedure can be reversed to test for a ReRound value.

    for i=2,3,4,etc
      remainder = value mod i
      if remainder==i-1 then not a ReRound
      otherwise
      value -= remainder    # round down to multiple of i
    stop when value <= i
    is a ReRound if value==i (and i is its index)

For example to test 28, it's a multiple of 2, so ok for the final rounding.
It's predecessor in the rounding steps was a multiple of 3, so round down to
a multiple of 3 which is 27.  The predecessor of 27 was a multiple of 4 so
round down to 24.  But at that point there's a contradiction because if 24
was the value then it's already a multiple of 3 and so wouldn't have gone up
to 27.  This case where a round-down gives a multiple of both i and i-1 is
identified by the remainder value % i == i-1, since the value is already a
multiple of i-1 and subtracting an i-1 would leave it still so.

=head1 SEE ALSO

L<Math::NumSeq>

=cut
