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

package Math::NumSeq::MathImageRadixConversion;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 97;

use Math::NumSeq;
@ISA = ('Math::NumSeq');
*_is_infinite = \&Math::NumSeq::_is_infinite;
*_bigint = \&Math::NumSeq::_bigint;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => Math::NumSeq::__('Radix Conversion');
use constant description => Math::NumSeq::__('Integers converted into another radix.');
use constant default_i_start => 0;
use constant characteristic_increasing => 1;
use constant characteristic_integer => 1;
use constant values_min => 0;

sub characteristic_smaller {
  my ($self) = @_;
  return ($self->{'to_radix'} < $self->{'radix'});

}

use constant parameter_info_array =>
  [
   { name          => 'radix',
     share_key     => 'radix_2',
     type          => 'integer',
     display       => Math::NumSeq::__('From Radix'),
     default       => 2,
     minimum       => 2,
     width         => 3,
     # description => Math::NumSeq::__('...'),
   },
   { name          => 'to_radix',
     share_key     => 'radix',
     type          => 'integer',
     display       => Math::NumSeq::__('To Radix'),
     default       => 10,
     minimum       => 2,
     width         => 3,
     # description => Math::NumSeq::__('...'),
   },
  ];


#------------------------------------------------------------------------------
# cf A136399 decimal is not entirely 0,1 digits
#    A001737 squares written in binary
#    A099820 even numbers written in binary
#    A099821 odd numbers written in binary
#    A178569 binary to decimal expressed by recurrance
#
#    A005836 base 3 without 2, is binary in base 3, but starts OFFSET=1 value=0

my @oeis_anum;
$oeis_anum[10]->[2] = 'A007088';  # numbers written in base 2, starting n=0
$oeis_anum[10]->[3] = 'A007089';  # numbers written in base 3, starting n=0
$oeis_anum[10]->[4] = 'A007090';  # numbers written in base 4, starting n=0
$oeis_anum[10]->[5] = 'A007091';  # numbers written in base 5, starting n=0
$oeis_anum[10]->[6] = 'A007092';  # numbers written in base 6, starting n=0
$oeis_anum[10]->[7] = 'A007093';  # numbers written in base 7, starting n=0
$oeis_anum[10]->[8] = 'A007094';  # numbers written in base 8, starting n=0
$oeis_anum[10]->[9] = 'A007095';  # numbers written in base 9, starting n=0
# OEIS-Catalogue: A007088
# OEIS-Catalogue: A007089 radix=3
# OEIS-Catalogue: A007090 radix=4
# OEIS-Catalogue: A007091 radix=5
# OEIS-Catalogue: A007092 radix=6
# OEIS-Catalogue: A007093 radix=7
# OEIS-Catalogue: A007094 radix=8
# OEIS-Catalogue: A007095 radix=9

$oeis_anum[4]->[2] = 'A000695';  # binary in base 4, starting n=0
# OEIS-Catalogue: A000695 to_radix=4
$oeis_anum[5]->[2]  = 'A033042';  # binary in base 5
$oeis_anum[6]->[2]  = 'A033043';  # binary in base 6
# $oeis_anum[7]->[2]  = 'A033044';  # binary in base 7, but OFFSET=1 value=0
$oeis_anum[8]->[2]  = 'A033045';  # binary in base 8
$oeis_anum[9]->[2]  = 'A033046';  # binary in base 9
$oeis_anum[11]->[2] = 'A033047';  # binary in base 11
$oeis_anum[12]->[2] = 'A033048';  # binary in base 12
$oeis_anum[13]->[2] = 'A033049';  # binary in base 13
$oeis_anum[14]->[2] = 'A033050';  # binary in base 14
$oeis_anum[15]->[2] = 'A033051';  # binary in base 15
$oeis_anum[16]->[2] = 'A033052';  # binary in base 16
# OEIS-Catalogue: A033042 to_radix=5
# OEIS-Catalogue: A033043 to_radix=6
# # OEIS-Catalogue: A033044 to_radix=7 # but OFFSET=1 value=0
# OEIS-Catalogue: A033045 to_radix=8
# OEIS-Catalogue: A033046 to_radix=9
# OEIS-Catalogue: A033047 to_radix=11
# OEIS-Catalogue: A033048 to_radix=12
# OEIS-Catalogue: A033049 to_radix=13
# OEIS-Catalogue: A033050 to_radix=14
# OEIS-Catalogue: A033051 to_radix=15
# OEIS-Catalogue: A033052 to_radix=16

sub oeis_anum {
  my ($self) = @_;

  if ($self->{'to_radix'} == $self->{'radix'}) {
    return 'A001477'; # all integers 0 up
  }
  # OEIS-Other: A001477 radix=10 to_radix=10
  # OEIS-Other: A001477 radix=2 to_radix=2

  return $oeis_anum[$self->{'to_radix'}]->[$self->{'radix'}];
}


#------------------------------------------------------------------------------

sub new {
  my $self = shift->SUPER::new(@_);

  # Round down to a power of to_radix as the UV limit.  For example in
  # 32-bits to_radix=10 the limit is 1_000_000_000.  Usually a bigger limit
  # is possible, but this round-down is an easy calculation.
  #
  my ($pow) = _round_down_pow (~0, $self->{'to_radix'});
  $self->{'value_uv_limit'} = $pow;
  ### value_uv_limit: $self->{'value_uv_limit'}

  return $self;
}

sub rewind {
  my ($self) = @_;
  $self->{'i'} = $self->i_start;
}
sub next {
  my ($self) = @_;
  my $i = $self->{'i'}++;
  my $value = $self->ith($i);
  if ($value == $self->{'value_uv_limit'}) {
    $self->{'i'} = _bigint()->new("$self->{'i'}");
  }
  return ($i, $value);
}

# ENHANCE-ME: BigInt use as_bin,oct.hex when to_radix decimal or likewise
#
sub ith {
  my ($self, $i) = @_;
  ### MathImageRadixConversion ith(): $i

  if (_is_infinite($i)) {
    return $i;
  }

  my $neg;
  if ($i < 0) {
    $neg = 1;
    $i = - $i;
  }
  my $value = _digit_join(_digit_split ($i, $self->{'radix'}),
                     $self->{'to_radix'});
  return ($neg ? -$value : $value);
}

sub _digit_split {
  my ($n, $radix) = @_;
  ### _digit_split(): $n
  my @ret;
  while ($n) {
    push @ret, $n % $radix;
    $n = int($n/$radix);
  }
  return \@ret;   # array[0] low digit
}

# $aref->[0] low digit
sub _digit_join {
  my ($aref, $radix) = @_;
  my $n = 0;
  while (defined (my $digit = pop @$aref)) {
    $n *= $radix;
    $n += $digit;
  }
  return $n;
}

sub pred {
  my ($self, $value) = @_;
  ### MathImageRadixConversion pred(): $value

  if (_is_infinite($value)) {
    return undef;
  }
  {
    my $int = int($value);
    if ($value != $int) {
      return 0;
    }
    $value = $int;
  }

  my $radix = $self->{'radix'};
  my $to_radix = $self->{'to_radix'};
  if ($to_radix < $radix) {
    return 1;
  }

  while ($value) {
    my $digit = $value % $to_radix;
    if ($digit >= $radix) {
      return 0;
    }
    $value = int($value/$to_radix);
  }
  return 1;
}

#------------------------------------------------------------------------------
# generic

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

=for stopwords Ryde Math-NumSeq

=head1 NAME

Math::NumSeq::MathImageRadixConversion -- radix conversion

=head1 SYNOPSIS

 use Math::NumSeq::MathImageRadixConversion;
 my $seq = Math::NumSeq::MathImageRadixConversion->new (radix => 2,
                                                        to_radix => 10);
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

This is integers converted from one radix to another.  The default is binary
converted to decimal,

    0, 1, 10, 11, 100, 101, 110, 111, 1000, 1001, 1010, 1011, ...

For example i=3 in binary is 0b11 which is interpreted as decimal for value
11, ie. eleven.

The C<radix> parameter is the from radix, and C<to_radix> what it's
converted to.

When C<radix E<lt> to_radix> the effect is to give all integers which in
C<to_radix> use only the digits of C<radix>.  So the default is all integers
which in decimal use only the binary digits, ie. 0 and 1.

When C<radix E<gt> to_radix> the conversion is a reduction.  The calculation
is still a breakdown and re-assembly

    dk*radix^k + d2*radix^2 + ... + d1*radix + d0 = i
    value = dk*to_radix^k + d2*to_radix^2 + ... + d1*to_radix + d0

but with C<to_radix> being smaller it's a reduction.  For example radix=10
i=123 with to_radix=8 gives 1*8^2+2*8+3=83.

=head1 FUNCTIONS

See L<Math::NumSeq/FUNCTIONS> for behaviour common to all sequence classes.

=over 4

=item C<$seq = Math::NumSeq::MathImageRadixConversion-E<gt>new ()>

=item C<$seq = Math::NumSeq::MathImageRadixConversion-E<gt>new (radix =E<gt> $r, to_radix =E<gt> $t)>

Create and return a new sequence object.

=item C<$value = $seq-E<gt>ith($i)>

Return C<$i> as digits of base C<radix> encoded in C<to_radix>.

=item C<$bool = $seq-E<gt>pred($value)>

Return true if C<$value> occurs in the sequence ...

=back

=head1 SEE ALSO

L<Math::NumSeq>,
L<Math::NumSeq::DigitSum>,
L<Math::NumSeq::HarshadNumbers>

=cut
