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

package App::MathImage::NumSeq::SqrtContfracPeriod;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 86;

use Math::NumSeq 7; # v.7 for _is_infinite()
use Math::NumSeq::Base::IterateIth;
@ISA = ('Math::NumSeq::Base::IterateIth',
        'Math::NumSeq');
*_is_infinite = \&Math::NumSeq::_is_infinite;

# uncomment this to run the ### lines
#use Smart::Comments;


use constant description => Math::NumSeq::__('Period of square root continued fractions.');
use constant characteristic_count => 1;
use constant characteristic_increasing => 0;
use constant i_start => 1;
use constant values_min => 0;

# cf A097853 contfrac sqrt(n) period, or 1 if square
#    A054269 contfract sqrt(prime) period
#
use constant oeis_anum => 'A003285'; # sqrt period, or 0 if square

sub ith {
  my ($self, $i) = @_;
  ### SqrtContfracPeriod ith(): $i

  if (_is_infinite($i)) {
    return $i;
  }
  if ($i <= 0) {
    return 0;
  }

  # initial a[1] = floor(sqrt(i)) = $root
  # then root + 1/x = sqrt(i)
  #      1/x = sqrt(i)-root
  #      x = 1/(sqrt(i)-root)
  #      x = (sqrt(i)+root)/(i-root*root)
  # so P = root
  #    Q = i - root*root
  #
  my $p = my $root = int(sqrt($i));
  my $q = $i - $root*$root;
  if ($q <= 0) {
    # perfect square
    return 0;
  }

  my %seen;
  my $count = 0;
  for (;;) {
    if ($seen{"$p,$q"}++) {
      return $count;
    }
    $count++;

    my $value = int (($root + $p) / $q);
    $p -= $value*$q;
    ($p, $q) = (-$p,
                ($i - $p*$p) / $q);

    ### assert: $p >= 0
    ### assert: $q >= 0
    ### assert: $p <= $root
    ### assert: $q <= 2*$root+1
    ### assert: (($p*$p - $i) % $q) == 0
  }
}

1;
__END__

=for stopwords Ryde Math-NumSeq BigInt

=head1 NAME

Math::NumSeq::SqrtContfracPeriod -- period of square root continued fractions

=head1 SYNOPSIS

 use Math::NumSeq::SqrtContfracPeriod;
 my $seq = Math::NumSeq::SqrtContfracPeriod->new;
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

This the period of the repeating part of the continued fraction expansion of
sqrt(i).

    0, 1, 2, 0, 1, 2, 4, 2, etc

For example sqrt(3) is 1 then two terms 1,2 repeating, for period 2.
Perfect squares terminate at the first term of the continued fraction, with
no repeating part, and the period for them is taken to be 0.

=head1 FUNCTIONS

See L<Math::NumSeq/FUNCTIONS> for the behaviour common to all path classes.

=over 4

=item C<$seq = Math::NumSeq::SqrtContfracPeriod-E<gt>new (sqrt =E<gt> $s)>

Create and return a new sequence object giving the Contfrac expansion terms of
C<sqrt($s)>.

=item C<$value = $seq-E<gt>ith ($i)>

Return the period of sqrt($i).

=back

=head1 SEE ALSO

L<Math::NumSeq>,
L<Math::NumSeq::SqrtContfrac>

=cut

# Local variables:
# compile-command: "math-image --values=SqrtContfracPeriod"
# End:
