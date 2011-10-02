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


# math-image --values=Fibbinary
#
# ZOrderCurve, ImaginaryBase tree shape
# DragonCurve repeating runs

package App::MathImage::NumSeq::Fibbinary;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 74;
use Math::NumSeq;
use Math::NumSeq::Base::IterateIth;
@ISA = ('Math::NumSeq::Base::IterateIth',
        'Math::NumSeq');
*_is_infinite = \&Math::NumSeq::_is_infinite;


# uncomment this to run the ### lines
#use Devel::Comments;

use constant values_min => 1;
use constant characteristic_monotonic => 1;
# use constant description => Math::NumSeq::__('');
use constant oeis_anum => 'A003714';  # Fibbinary


sub ith {
  my ($self, $i) = @_;
  ### Fibbinary ith(): $i

  if (_is_infinite($i)) {
    return $i;
  }

  my $f0 = 1;
  my $f1 = 1;
  ### above: "$f1,$f0"
  while ($i >= $f1) {
    ($f1,$f0) = ($f1+$f0,$f1);
  }
  ### above: "$f1,$f0"
  
  my $value = 0;
  while ($f0 > 0) {
    ### at: "$f1,$f0  value=$value"
    $value *= 2;
    if ($i >= $f1) {
      $i -= $f1;
      $value += 1;
      ### sub: "$f1 to i=$i value=$value"
  
      ($f1,$f0) = ($f0,$f1-$f0);
      last unless $f0 > 0;
      $value *= 2;
    }
    ($f1,$f0) = ($f0,$f1-$f0);
  }
  return $value;
}


sub pred {
  my ($self, $value) = @_;
  # ### Fibbinary pred(): $value
  return ($value ^ (2*$value)) == 3*$value;
}

1;
__END__

=for stopwords Ryde Math-NumSeq

=head1 NAME

Math::NumSeq::Fibbinary -- without consecutive 1 bits

=head1 SYNOPSIS

 use Math::NumSeq::Fibbinary;
 my $seq = Math::NumSeq::Fibbinary->new;
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

The fibbinary numbers 0, 1, 2, 4, 5, 8, 9, 10, etc, being integers which
don't have consecutive 1 bits in binary.

These bits also represent Fibonacci numbers used to represent i in the
Zeckendorf style Fibonacci base.  In that system an integer i is represented
as a sum of Fibonacci numbers, for example i=20 is 13+5+1, which is the
sixth, fourth and first Fibonacci numbers and becomes fibbinary 101001
binary which is 41.  So at i=20 in the fibbinary number is 41.

There's more than one way to represent an integer as a sum of Fibonacci
numbers, the rule in the Zeckendorf system is that each number can be used
only once, and no consecutive numbers can be used.  With that restriction
every integer is single unique sum.

=head1 FUNCTIONS

See L<Math::NumSeq/FUNCTIONS> for the behaviour common to all path classes.

=over 4

=item C<$seq = Math::NumSeq::All-E<gt>new (key=E<gt>value,...)>

Create and return a new sequence object.

=item C<$value = $seq-E<gt>ith($i)>

Return the C<$i>'th fibbinary number.

=item C<$bool = $seq-E<gt>pred($value)>

Return true if C<$value> is a fibbinary number, which means that in binary
it doesn't have two consecutive 1 bits..

=back

=head1 SEE ALSO

L<Math::NumSeq>,
L<Math::NumSeq::Fibonacci>

=cut
