# Copyright 2011 Kevin Ryde

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

package App::MathImage::NumSeq::ReRound;
use 5.004;
use strict;
use POSIX 'ceil';
use List::Util 'max';

use vars '$VERSION','@ISA';
$VERSION = 84;

use Math::NumSeq;
use Math::NumSeq::Base::IterateIth;
@ISA = ('Math::NumSeq::Base::IterateIth',
        'Math::NumSeq');

# uncomment this to run the ### lines
#use Smart::Comments;

use constant description => Math::NumSeq::__('...');
use constant values_min => 1; # at i=1
use constant i_start => 1;
use constant characteristic_increasing => 1;

# A000959 lucky numbers 1, 3, 7, 9, 13, 15, 21, delete per first remaining
# A145649 characteristic
# A050505 complement
# A007952 sieve+1
#
# A000960  Flavius Josephus sieve twice rounding
#
use constant oeis_anum => 'A002491';   # Mancala stones ...

sub ith {
  my ($self, $i) = @_;
  for (my $m = $i-1; $m >= 2; $m--) {
    $i += (-$i % $m);
  }
  return $i;
}

sub pred {
  my ($self, $value) = @_;
  ### ReRound pred(): $value

  unless ($value >= 2 && $value == int($value)) {
    return ($value == 1);
  }
  if ($value % 2) {
    return 0;
  }

  my $m = 2;
  while ($value > $m) {
    my $rem;
    if (($rem = ($value % ($m+1))) == $m) {
      return 0;
    }
    $value -= $rem;
    $m++;

    ### $m
    ### subtract rem: $rem
    ### $value
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

App::MathImage::NumSeq::ReRound -- sequence from repeated rounding up

=head1 SYNOPSIS

 use App::MathImage::NumSeq::ReRound;
 my $seq = App::MathImage::NumSeq::ReRound->new;
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

This is the sequence of values formed by repeatedly rounding up to a
multiple of i-1,i-2,...,2.  For example i=5 is rounded up to a multiple of 4
to give 8, then rounded up to a multiple of 3 to give 9, then rounded up to
a multiple of 2 for value 10 at i=5.

When rounding up if a value is already a suitable multiple then it's
unchanged.  For example i=4 round up to a multiple of 3 to give 6, then
round up to a multiple of 2 is unchanged 6 since it's already a multiple
of 2.

Because the last step rounds up to a multiple of 2 the values are all even.
They're also monotonically increasing and end up approximately (i^2)/pi,
though both bigger and smaller than that estimate occur.

=head1 FUNCTIONS

=over 4

=item C<$seq = App::MathImage::NumSeq::ReRound-E<gt>new (key=E<gt>value,...)>

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
    is a ReRound if value==i (in which case i is its index)

For example to test 28, it's predecessor in the round-up steps must have
been a multiple of 3, so round down to a multiple of 3 which is 27.  The
predecessor at 27 was a multiple of 4 so round down to 24.  But at that
point there's a contradiction because if 24 was the value then it was
already a multiple of 3 and so wouldn't have gone up to 27.  This case where
a round-down gives a multiple of both i and i-1 is identified by the
remainder value % i equal to i-1, since the value is already a multiple of
i-1 and subtracting an i-1 would leave it still so.

=head1 SEE ALSO

L<Math::NumSeq>

=cut

# Local variables:
# compile-command: "math-image --values=ReRound"
# End:
