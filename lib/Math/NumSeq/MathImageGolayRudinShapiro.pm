# Copyright 2010, 2011, 2012 Kevin Ryde

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

package Math::NumSeq::MathImageGolayRudinShapiro;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 95;

use Math::NumSeq;
use Math::NumSeq::Base::IteratePred;
@ISA = ('Math::NumSeq::Base::IteratePred',
        'Math::NumSeq');

# uncomment this to run the ### lines
#use Smart::Comments;


# cf 
#    A020985 - 1 and -1
#    A020986 - cumulative 1,-1, always positive?
#    A020987 - 0 and 1
#    A014081 - count of 11 bit pairs
#    A020990 - cumulative but flip sign at odd i
#    A020991 - highest occurrance of N in the partial sums.
#
use constant description => Math::NumSeq::__('Golay/Rudin/Shapiro sequence -1 positions, being 3,6,11,12,13,15,etc numbers which have an odd number of "11" bit pairs in binary.');
use constant values_min => 3;
use constant i_start => 1;
use constant oeis_anum => 'A022155';  # positions of -1s

sub pred {
  my ($self, $value) = @_;
  if ($value < 0) { return 0; }

  # N & Nshift leaves bits with a 1 below them, then parity of bit count
  $value &= ($value >> 1);
  return (1 & unpack('%32b*', pack('I', $value)));
}

# Jorg Arndt fxtbook increment by
# low 1s 0111 increment to 1000
# if even number of 1s then that's a "11" parity change
# if the 1000 has a 1 above it then that's a parity change too
#
# so 1000 at an odd bit position, xor the bit above it

1;
__END__

=for stopwords Ryde OEIS

=head1 NAME

Math::NumSeq::MathImageGolayRudinShapiro -- numbers with odd number of "11" adjacent 1-bits

=head1 SYNOPSIS

 use Math::NumSeq::MathImageGolayRudinShapiro;
 my $seq = Math::NumSeq::MathImageGolayRudinShapiro->new;
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

This is a sequence arising from a sieve replacing multiples described be
David Madore,

    1, 2, 1, 2, 3, 3, 1, 2, 4, 4, 3, 4, ...

The sieve begins with all 1s,

    1,1,1,1,1,1,1,1,1,1,1,1,...

Then every second 1 is changed to 2

    1,2,1,2,1,2,1,2,1,2,1,2,...

Then every third 1 is changed to 3, and every third 2 changed to 3 also,

    1,2,1,2,3,3,1,2,1,2,3,3,...

Then every fourth 1 becomes 4, fourth 2 becomes 4, fourth 3 becomes 4.

    1,2,1,2,3,3,1,2,4,4,3,4,...

The replacement of every Nth with N is applied separately to the 1s, 2s, 3s
etc remaining in the sieve at each stage.

=head1 FUNCTIONS

=over 4

=item C<$seq = Math::NumSeq::MathImageGolayRudinShapiro-E<gt>new ()>

Create and return a new sequence object.

=back

=head1 SEE ALSO

L<Math::NumSeq>

=cut
