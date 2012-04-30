# sum of two squares
#
# including_zero => bool
# including_order => bool




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

package Math::NumSeq::MathImageHypotCount;
use 5.004;
use strict;
use POSIX 'ceil';

use vars '$VERSION', '@ISA';
$VERSION = 97;
use Math::NumSeq;
@ISA = ('Math::NumSeq');
*_is_infinite = \&Math::NumSeq::_is_infinite;

use Math::Factor::XS 'prime_factors';


# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => Math::NumSeq::__('Count Hypotenuses');
use constant description => Math::NumSeq::__('Count of ways to be a sum of two squares, A^2+B^2 for integer A,B >=0.');
use constant i_start => 0;
use constant characteristic_count => 1;
use constant characteristic_increasing => 0;
use constant values_min => 0;

# cf A002654 num ways nonzero squares with ordered a,b
#    A000161 num ways squares with zeros without distingishing order
#    A001481 numbers which have at least one rep
#
use constant oeis_anum => 'A000161'; # with zeros without order

# sub new {
#   my ($class, %options) = @_;
#   ### HypotCount new()
# 
#   $options{'lo'} = max (0, $options{'lo'}||0);
#   my $hi = $options{'hi'} = max (0, $options{'hi'});
# 
#   my $str = "\0\0\0\0" x ($options{'hi'}+1);
#   for (my $j = 2; $j <= $hi; $j += 2) {
#     vec($str, $j,8) = 2*1-1;
#   }
#   return $class->SUPER::new (%options,
#                              string => $str);
# }
# 
# sub rewind {
#   my ($self) = @_;
#   ### HypotCount rewind()
#   $self->{'i'} = 0;
#   while ($self->{'i'} < $self->{'lo'}-1) {
#     $self->next;
#   }
# }
# 
# sub next {
#   my ($self) = @_;
#   ### HypotCount next() from: $self->{'i'}
# 
#   my $i = $self->{'i'}++;
#   my $hi = $self->{'hi'};
#   if ($i > $hi) {
#     return;
#   }
#   my $cref = \$self->{'string'};
# 
#   my $ret = vec ($$cref, $i,8);
#   if ($ret == 0 && $i >= 3 && ($i&3) == 1) {
#     ### prime 4k+1: $i
#     $ret = 1;
#     for (my $j = $i; $j <= $hi; $j += $i) {
#       vec($$cref, $j,8) ++;
#     }
# 
#     # print "applied: $i\n";
#     # for (my $j = 0; $j < $hi; $j++) {
#     #   printf "  %2d %2d\n", $j, vec($$cref, $j,8);
#     # }
#   }
#   return ($i, $ret);
# }
# 
# sub pred {
#   my ($self, $n) = @_;
#   ### HypotCount pred(): $n
#   return 1;
# }



sub rewind {
  my ($self) = @_;
  $self->{'i'} = $self->i_start;
}
sub next {
  my ($self) = @_;
  my $i = $self->{'i'}++;
  return ($i, $self->ith($i));
}

# 25 = 0^2+5^2 = 3^2+4^2
# 25 = 5^2  b1=2 B=(2+1)=3 a0=0 B-(-1)^a0=3-1=2 so 2/2=1
# 25 = 2^1*5^2  b1=2 B=(2+1)=3 a0=1 B-(-1)^a0=3-(-1)=4 so 4/2=2

sub ith {
  my ($self, $i) = @_;
  ### HypotCount ith(): $i

  if (_is_infinite($i)) {
    return $i;
  }
  if ($i < 0) {
    ### nothing for negatives ...
    return 0;
  }
  unless ($i <= 0xFFFF_FFFF) {
    return undef;
  }

  if ($i < 2) {
    return 1;
  }

  # {
  #   my $count = 0;
  #   my $r = int(sqrt($i));
  #   for (my $x = ceil(sqrt($i)/2); $x <= $r; $x++) {
  #     my $y = sqrt($i - $x*$x);
  #     $count += ($y <= $x && $y == int($y));
  #     ### add: "$x,$y  ".($y == int($y))
  #   }
  #   return $count;
  # }

  my @primes = prime_factors($i);

  my $pow2 = 1;
  while (@primes && $primes[0] == 2) {
    shift @primes;
    $pow2 = -$pow2;
  }
  ### $pow2

  my $ret = 1;
  my $nonsquare = 0;
  while (@primes) {
    my $p = shift @primes;
    my $count = 1;
    while (@primes && $primes[0] == $p) {
      shift @primes;
      $count++;
    }
    if ($p & 2) {  # p==4k+3
      if ($count&1) {
        return 0;  # odd power of 4k+3
      }
    } else {  # p==4k+1
      ### of 4k+1: $count
      $ret *= $count+1;
      $nonsquare ||= ($count&1);
    }
  }
  ### after primes: $ret

  if ($ret & 1) {
    $ret -= $pow2;
    ### with pow2: $ret
  }
  unless ($nonsquare || $pow2 < 0) {
    $ret += 2;  # $i is a perfect square
  }
  return $ret / 2;


}

sub pred {
  my ($self, $value) = @_;
  return ($value >= 0 && $value == int($value));
}

1;
__END__

=for stopwords Ryde MathImage

=head1 NAME

Math::NumSeq::MathImageHypotCount -- how many times as sum of two squares

=head1 SYNOPSIS

 use Math::NumSeq::MathImageHypotCount;
 my $seq = Math::NumSeq::MathImageHypotCount->new;
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

I<In progress ...>

The counts of how many times i occurs as the sum of two squares i=A^2+B^2
for integer A,B.

    1, 1, 1, 0, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0, 1, ...

One or both A,B can be zero, but swapping to B^2+A^2 is not reckoned as a
different way.  For example i=5 has just one way 1^2+2^2=5.  But i=6 has no
way to add two squares to make 6.

Allowing A=0 means the perfect squares i=k^2 all have a count of at least
one way 0^2+k^2 = k^2, and there may be more ways too.

=head1 FUNCTIONS

See L<Math::NumSeq/FUNCTIONS> for behaviour common to all sequence classes.

=over 4

=item C<$seq = Math::NumSeq::MathImageHypotCount-E<gt>new ()>

Create and return a new sequence object.

=item C<$value = $seq-E<gt>ith($i)>

Return the number of ways C<$i> can be expressed as the sum of two squares.

This requires factorizing C<$i> and the current code has a hard limit of
2**32 on C<$i>, in the interests of not going into a near-infinite loop.

=item C<$bool = $seq-E<gt>pred($value)>

Return true if C<$value> occurs as a count.  All counts 0 up occur so this
is simply integer C<$value E<gt>= 0>.

=back

=head1 SEE ALSO

L<Math::NumSeq>,
L<Math::NumSeq::PythagoreanHypots>

=cut



# The number of ways is related to prime factors 4k+1 and 4k+3 in i.  If
# 
#     i = 2^t * p1^a1 * p2^a2 * ... * q1^b1 * q2^b2 * ...
# 
#     p primes 4k+1
#     q primes 4k+3
# 
# then
# 
# MAYBE ...
#     count = /  0 if any b is odd
#             |  (a1+1)*...*(ak+1) / 2  if any a odd
#             \  ((a1+1)*...*(ak+1) - (-1)^t) / 2  if all a even
# 
# So any i with an odd powered prime factor 4k+3 has no representations.
# For example i=3 is the first such.  Otherwise the powers of the 4k+1
# primes determine the count.

