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


# 
#
# ZOrderCurve, ImaginaryBase tree shape
# DragonCurve repeating runs
#
# cf fxtbook ch38 p756


package App::MathImage::NumSeq::FibbinaryBitCount;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 81;
use Math::NumSeq;
use Math::NumSeq::Base::IterateIth;
@ISA = ('Math::NumSeq::Base::IterateIth',
        'Math::NumSeq');
*_is_infinite = \&Math::NumSeq::_is_infinite;


# uncomment this to run the ### lines
#use Smart::Comments;

use constant values_min => 0;
use constant characteristic_monotonic => 0;
use constant characteristic_count => 1;
use constant description => Math::NumSeq::__('Bit count of fibbinary numbers, being values without adjacent 1 bits.');

# cf A027941 new highest count positions, being Fibonacci(2i+1)-1
#
use constant oeis_anum => 'A007895';  # fibbinary bit count

sub ith {
  my ($self, $i) = @_;
  ### FibbinaryBitCount ith(): $i

  if (_is_infinite($i)) {
    return $i;
  }

  # f1+f0 > i
  # f0 > i-f1
  # check i-f1 as the stopping point, so that if i=UV_MAX then won't
  # overflow a UV trying to get to f1>=i
  #
  my @fibs;
  {
    my $f0 = ($i * 0);  # inherit bignum 0
    my $f1 = $f0 + 1;   # inherit bignum 1
    @fibs = ($f0);
    while ($f0 <= $i-$f1) {
      ($f1,$f0) = ($f1+$f0,$f1);
      push @fibs, $f1;
    }
  }
  ### @fibs

  my $count = 0;
  while (my $f = pop @fibs) {
    ### at: "$f  i=$i count=$count"
    if ($i >= $f) {
      $count++;
      ($i -= $f) || last;  # stop if now 0
      ### sub: "$f to i=$i"
      # never consecutive fibs, so pop without comparing to i
      pop @fibs;
    }
  }
  return $count;
}

sub pred {
  my ($self, $value) = @_;
  return ($value >= 0 && $value == int($value));
}

1;
__END__

=for stopwords Ryde Math-NumSeq fibbinary Zeckendorf k's Ith i'th

=head1 NAME

App::MathImage::NumSeq::FibbinaryBitCount -- number of bits in each fibbinary number

=head1 SYNOPSIS

 use App::MathImage::NumSeq::FibbinaryBitCount;
 my $seq = App::MathImage::NumSeq::FibbinaryBitCount->new;
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

The number of 1 bits in the i'th fibbinary number.

=head1 FUNCTIONS

See L<Math::NumSeq/FUNCTIONS> for the behaviour common to all path classes.

=over 4

=item C<$seq = App::MathImage::NumSeq::FibbinaryBitCount-E<gt>new (key=E<gt>value,...)>

Create and return a new sequence object.

=item C<$value = $seq-E<gt>ith($i)>

Return the bit count of the C<$i>'th fibbinary number.

=item C<$bool = $seq-E<gt>pred($value)>

Return true if C<$value> occurs as a bit count, which simply means C<$value
E<gt>= 0>.

=back

=head1 SEE ALSO

L<Math::NumSeq>,
L<Math::NumSeq::Fibbinary>

=cut

# Local variables:
# compile-command: "math-image --values=FibbinaryBitCount"
# End:
