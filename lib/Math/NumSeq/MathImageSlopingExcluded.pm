# download related seqs
# similar works in other bases .. SlopingExcluded



# Copyright 2012 Kevin Ryde

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

package Math::NumSeq::MathImageSlopingExcluded;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 97;

use Math::NumSeq;
use Math::NumSeq::Base::IterateIth;
@ISA = ('Math::NumSeq::Base::IterateIth',
        'Math::NumSeq');
*_is_infinite = \&Math::NumSeq::_is_infinite;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => Math::NumSeq::__('Sloping Digits Excluded');
use constant description => Math::NumSeq::__('Integers not occurring as sloping binary, or selected radix.');
use constant characteristic_increasing => 1;
use constant default_i_start => 1;

# "radix" parameter
use Math::NumSeq::Base::Digits;
*parameter_info_array = \&Math::NumSeq::Base::Digits::parameter_info_array;

sub values_min {
  my ($self) = @_;
  return $self->{'radix'} - 1;
}

#------------------------------------------------------------------------------

# cf A102370 sloping binary
#    A103529 sloping binary which go past a new 2^k
#    A103530   diff A103529-2^k which it went past
#    A102371 sloping binary excluded [this seq]
#    A103581 sloping binary excluded, written in binary
#
#    A103582 0,1,0,1 or 0,0,1,1 etc diagonals downwards
#    A103583 0,1,0,1 or 0,0,1,1 etc diagonals upwards
#
# 1,2,7,12,29,62,123,248,505,...
my @oeis_anum = (
                 # OEIS-Catalogue array begin
                 undef,
                 undef,
                 'A102371', # radix=2
                 # OEIS-Catalogue array end
                );
sub oeis_anum {
  my ($self) = @_;
  return $oeis_anum[$self->{'radix'}];
}

#------------------------------------------------------------------------------

# i-k = 0 mod 2^k
# always i itself counts +2^i
# others i<2^k
#
# n=2 start -2
# 2-1 mod 2 = 1
# 2-2 mod 4 = 0 count +4 total 4-2=2
#
# n=3 start -3
# 3-1 mod 2 = 0 count +2
# 3-2 mod 4 = 1
# 3-3 mod 8 = 0 count +8 total 8+2-3=7
#
# n=4 start -4
# 4-1 mod 2 = 1
# 4-2 mod 4 = 2
# 4-3 mod 8 = 1
# 4-4 mod 16 = 0 count +16 total 16-4=13

sub ith {
  my ($self, $i) = @_;

  if (_is_infinite($i)) {
    return $i;
  }

  my $radix = $self->{'radix'};
  my $value = Math::NumSeq::_bigint()->new($radix) ** $i - 1;
  my $offset = $i-1;
  my $power = Math::NumSeq::_bigint()->new(1);

  foreach (1 .. $i) {
    my $next_power = $power * $radix;
    my $digit = $offset % $next_power;
    $digit -= $digit % $power;
    $value -= $digit;

    $power = $next_power;
    last if $offset < $power;  # further digits all zero
    $offset--;
  }
  return $value;
  


  # my $one = ($i >= 30
  #             ? Math::NumSeq::_bigint()->new(1)
  #             : 1);
  # my $value = ($one << $i) - $i;
  # my $k = 1;
  # my $mask = 1;
  # while ($mask < $i) {
  #   if ((($i-$k) & $mask) == 0) {
  #     $value += $mask + 1;
  #   }
  #   $k++;
  #   $mask = ($mask << 1) + 1;
  # }
  # return $value;
}

sub pred {
  my ($self, $value) = @_;
  ### pred(): "$value"

  if (_is_infinite($value)) {
    return undef;
  }
  my $radix = $self->{'radix'};
  if ($value < $radix) {
    return ($value == $radix-1);
  }

  my ($pow, $i) = _round_down_pow($value, $radix);
  ### pow: "$pow"
  ### i: "$i"
  ### ith(i+1): $self->ith($i+1).''

  return ($value == $self->ith($i+1));
}

sub value_to_i_estimate {
  my ($self, $value) = @_;
  ### value_to_i_estimate: $value

  if (defined (my $blog2 = _blog2_estimate($value))) {
    return $blog2;
  } else {
    return int(log($value) * (1/log(2)));
  }
}

#------------------------------------------------------------------------------
# generic

# use Math::NumSeq::NumAronson;
# *_round_down_pow = \&Math::NumSeq::NumAronson::_round_down_pow;
#
# use Math::NumSeq::Fibonacci;
# *_blog2_estimate = \&Math::NumSeq::Fibonacci::_blog2_estimate;


# if $n is a BigInt, BigRat or BigFloat then return an estimate of log base 2
# otherwise return undef.
#
# For Math::BigInt
#
# For BigRat the calculation is just a bit count of the numerator less the
# denominator so may be off by +/-1 or +/-2 or some such.  For
#
sub _blog2_estimate {
  my ($n) = @_;

  if (ref $n) {
    ### _blog2_estimate(): "$n"

    if ($n->isa('Math::BigRat')) {
      return ($n->numerator->copy->blog(2) - $n->denominator->copy->blog(2))->numify;
    }
    if ($n->isa('Math::BigFloat')) {
      return $n->as_int->blog(2)->numify;
    }
    if ($n->isa('Math::BigInt')) {
      return $n->copy->blog(2)->numify;
    }
  }
  return undef;
}

# return ($pow, $exp) with $pow = $base**$exp <= $n,
# the next power of $base at or below $n
#
sub _round_down_pow {
  my ($n, $base) = @_;
  ### _round_down_pow(): "$n base $base"

  if ($n < $base) {
    return (1, 0);
  }

  # Math::BigInt and Math::BigRat overloaded log() return NaN, use integer
  # based blog()
  if (ref $n && ($n->isa('Math::BigInt') || $n->isa('Math::BigRat'))) {
    my $exp = $n->copy->blog($base);
    return (Math::BigInt->new(1)->blsft($exp,$base),
            $exp);
  }

  my $exp = int(log($n)/log($base));
  my $pow = $base**$exp;

  # check how $pow actually falls against $n, not sure should trust float
  # rounding in log()/log($base)
  # Crib: $n as first arg in case $n==BigFloat and $pow==BigInt
  if ($n < $pow) {
    ### hmm, int(log) too big, decrease...
    $exp -= 1;
    $pow = $base**$exp;
  } elsif ($n >= $base*$pow) {
    ### hmm, int(log) too small, increase...
    $exp += 1;
    $pow *= $base;
  }
  return ($pow, $exp);
}

1;
__END__

=for stopwords Ryde MathImage

=head1 NAME

Math::NumSeq::MathImageSlopingExcluded -- numbers not occurring in sloping binary

=head1 SYNOPSIS

 use Math::NumSeq::MathImageSlopingExcluded;
 my $seq = Math::NumSeq::MathImageSlopingExcluded->new;
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

I<In progress ...>

The numbers not occurring in sloping binary,

    1, 2, 7, 12, 29, 62, 123, 248, 505, 1018, 2047, 4084, 8181, ...

Sloping binary numbers by David Applegate, Benoit Cloitre, Philippe
DelE<233>ham and Neil Sloane are defined by writing integers in binary and
reading on an upwards diagonal slope skipping the high 1 bit.

    integers   sloping
         0        0
         1
        /
       1 0       11   = 3
        /
       1 1
      / /
     1 0 0      110   = 6
      / /
     1 0 1      101   = 5
      / /
     1 1 0      100   = 4
      /
     1 1 1
    /
   1 0 0 0      1111  = 15

It can be shown that the values resulting give all the integers, except one
near each power 2^k.  The sequence here is those excluded values.

=head1 FUNCTIONS

See L<Math::NumSeq/FUNCTIONS> for behaviour common to all sequence classes.

=over 4

=item C<$seq = Math::NumSeq::MathImageSlopingExcluded-E<gt>new ()>

Create and return a new sequence object.

=item C<$value = $seq-E<gt>ith($i)>

Return the C<$i>'th value which is not in sloping binary.

=item C<$bool = $seq-E<gt>pred($value)>

Return true if C<$value> is not included in sloping binary.

=back

=head1 SEE ALSO

L<Math::NumSeq>

=cut
