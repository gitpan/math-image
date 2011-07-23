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

package App::MathImage::NumSeq::Proth;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 65;

use App::MathImage::NumSeq '__';
use App::MathImage::NumSeq::Base::IterateIth;
@ISA = ('App::MathImage::NumSeq::Base::IterateIth',
        'App::MathImage::NumSeq');

# uncomment this to run the ### lines
#use Devel::Comments;

use constant name => __('Proth Numbers');
use constant description => __('Proth numbers k*2^n+1 for odd k and k < 2^n.');
use constant values_min => 3;
use constant i_start => 1;

# cf A157892 - value of k
#    A157893 - value of n
#    A080076 - Proth primes
#    A134876 - how many Proth primes for given n
#
#    A002253
#    A002254
#    A032353
#    A002256
#
use constant oeis_anum => 'A080075';

# ENHANCE-ME: for next() keep the k and its increment 

sub pred {
  my ($self, $value) = @_;
  ### Proth pred(): $value
  ($value >= 3 && $value & 1) or return 0;
  my $pow = 2;
  for (;;) {
    ### at: "$value   $pow"
    $value >>= 1;
    if ($value < $pow) {
      return 1;
    }
    if ($value & 1) {
      return ($value < $pow);
    }
    $pow <<= 1;
  }
}

sub ith {
  my ($self, $i) = @_;
  ### Proth ith(): $i
  if ($i == 1) {
    return 3;
  }
  $i += 1;

  if ($i == $i-1) {
    return $i;  # don't loop forever if $i is +infinity
  }

  my $exp = ($i & 0);  # inherit
  my $rem = $i;
  while ($rem > 3) {
    $rem >>= 1;
    $exp++;
  }
  my $bit = 2**$exp;

  ### i: sprintf('0b%b', $i)
  ### bit: sprintf('0b%b', $bit)
  ### $rem
  ### high: sprintf('0b%b', ($i - $bit*($rem-1)))
  ### rem factor: ($rem - 1)
  ### so: sprintf('0b%b', ($i - $bit*($rem-1)) * $bit * ($rem - 1) + 1)
  ### assert: $rem==2 || $rem==3

  $rem--;  # now 2 or 1
  return ($i - $bit*$rem) * 2 * $rem*$bit + 1;
}

1;
__END__

=for stopwords Ryde MathImage Proth Ith ith zxxx zxx x's hxx hh

=head1 NAME

App::MathImage::NumSeq::Proth -- Proth number sequence

=head1 SYNOPSIS

 use App::MathImage::NumSeq::Squares;
 my $seq = App::MathImage::NumSeq::Squares->new;
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

The Proth numbers 3, 5, 9, 13, 17, etc, being integers k*2^n+1 where k E<lt>
2^n.

The condition k E<lt> 2^n means the values in binary have low half 1 and
high half some value k,

          binary
     3      11   
     5      101    
     9     1001
    13     1101
    17     10001
    25     11001
    33    100001
          ^^^
            +----- k part

=head1 FUNCTIONS

=over 4

=item C<$seq = App::MathImage::NumSeq::Proth-E<gt>new()>

Create and return a new sequence object.

=item C<$value = $seq-E<gt>ith($i)>

Return the C<$i>'th Proth number.  The first number is 3 at C<$i==1>.

=item C<$bool = $seq-E<gt>pred($value)>

Return true if C<$value> is a Proth number, meaning is equal to k*2^n+1 for
some k and n.

=back

=head1 FORMULAS

=head2 Ith

Taking the values by their length in bits, the values are

       11        1 value  i=1
       101       1 value  i=2
      1x01       2 values i=3,4
      1x001      2 values i=5,6
     1xx001      4 values i=7 to 10
     1xx0001     4 values 
    1xxx0001     8 values
    1xxx00001    8 values

For a given 1xxx high part the low zeros, which is the 2^n factor, is the
same length and then repeated 1 bigger.  That doubling can be controlled by
a high bit of the i, so in the following Z is either a zero bit or omitted,

       1Z1       
      1xZ01      
     1xxZ001     
    1xxxZ0001

The ith Proth number can be formed from the bits of the index

    i+1 = 1zxx..xx    binary
    k = 1xx..xx
    n = z + 1 + number of x's

The first 1zxxx desired is 10, which is had from i+1 starting from i=1.  The
z second highest bit makes n bigger, giving the Z above present or omitted.

For example i=9 is bits i+1=1010 binary which as 1zxx is k=0b110=6,
n=0+1+2=3, for value 6*2^3+1=49, or binary 110001.

It can be convenient to take the two highest bits of the index i together,
so hhxx..xx so hh=2 or 3, then n = hh-1 + number of x's.

=head1 SEE ALSO

L<App::MathImage::NumSeq>,
L<App::MathImage::NumSeq::Cullen>,
L<App::MathImage::NumSeq::Woodall>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-image/index.html

=head1 LICENSE

Copyright 2010, 2011 Kevin Ryde

Math-Image is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation; either version 3, or (at your option) any later
version.

Math-Image is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
Math-Image.  If not, see <http://www.gnu.org/licenses/>.

=cut
