# binary pred() wrong ?
#
# option min length ?
# option A==B ?



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

package Math::NumSeq::MathImageUndulatingNumbers;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 90;
use Math::NumSeq;
@ISA = ('Math::NumSeq');


# uncomment this to run the ### lines
#use Smart::Comments;

# use constant name => Math::NumSeq::__('Undulating Numbers');
use constant description => Math::NumSeq::__('Numbers like 37373 which are a pattern of digits ABAB...');
use constant i_start => 0;
use constant characteristic_increasing => 1;
use constant values_min => 0;

use Math::NumSeq::Base::Digits;
use constant parameter_info_array =>
  [
   Math::NumSeq::Base::Digits::parameter_common_radix(),
   { name        => 'including_repdigits',
     type        => 'boolean',
     display     => Math::NumSeq::__('Repdigits'),
     default     => 1,
     description => Math::NumSeq::__('Whether to include repdigits A=B.'),
   },
  ];

# A046075 base 10 >=101 with a!=b
#
# cf A046076 "binary undulants", 2^N in decimal has 010 or 101 somewhere
#
my @oeis_anum;
$oeis_anum[1]->[10] = 'A033619'; # decimal incl A=B, start i=0 value=0
# OEIS-Catalogue: A033619 including_repdigits=1
#
sub oeis_anum {
  my ($self) = @_;
  return $oeis_anum[!!$self->{'including_repdigits'}]->[$self->{'radix'}];
}

sub rewind {
  my ($self) = @_;
  my $radix = $self->{'radix'};
  if ($radix < 2) { $radix = 10; }
  $self->{'radix'} = $radix;

  $self->{'i'}     = 0;
  $self->{'n'}     = -1;
  $self->{'inc'}   = 1;
  $self->{'a'}     = 0;
  $self->{'b'}     = 0;
}

sub next {
  my ($self) = @_;
  ### UndulatingNumbers next()

  my $radix = $self->{'radix'};
  my $n;
  if ($n = ($self->{'n'} += $self->{'inc'})) {
    $self->{'b'}++;
    ### n: $self->{'n'}
    ### a: $self->{'a'}
    ### b: $self->{'b'}

    if (! $self->{'including_repdigits'}
        && $self->{'b'} == $self->{'a'}) {
      $self->{'b'}++;
      $self->{'n'} = ($n += $self->{'inc'});
      ### skip a to b: $self->{'b'}
      ### n now: $n
    }

    if ($self->{'b'} >= $radix ) {
      $self->{'b'} = 0;
      $self->{'n'} = ($n += ($self->{'inc'} & 1) ^ 1);
      ### a inc
      ### n now: $n

      if (++$self->{'a'} >= $radix) {
        # 101 -> 1010
        # or 1010 -> 10101
        my $low = $self->{'inc'} & 1;
        $self->{'inc'} = $self->{'inc'} * $radix + !$low;
        $self->{'a'} = 1;
        $self->{'n'} = ($n += $low);
        ### lengthen to inc: $self->{'inc'}
        ### n now: $n
      }
    }
  }
  return ($self->{'i'}++, $n);
}

# not quite right ...
# sub ith {
#   my ($self, $i) = @_;
#   ### UndulatingNumbers ith(): $i
#   my $radix = $self->{'radix'};
#   my $rdec = $radix - 1;
# 
#   my $including_repdigits = $self->{'including_repdigits'};
# 
#   my $pair_step = $rdec*($including_repdigits ? $rdec : $radix);
#   my $i_pair = $i % $pair_step;
#   my $i_len = int($i/$pair_step);
#   ### $i_pair
#   ### $i_len
# 
#   my ($a, $b);
#   if ($including_repdigits) {
#     $a = int($i_pair/$radix) + 1;
#     $b = $i_pair % $radix;
#   } else {
#     $a = int($i_pair/$rdec) + 1;
#     $b = $i_pair % $rdec;
#     $b += ($b >= $a);
#   }
#   ### $a
#   ### $b
# 
#   my $ret = ($a*$radix + $b)*$radix + $a;
#   while ($i_len--) {
#     $ret = ($ret * $radix) + $a;
#     last unless $i_len--;
#     $ret = ($ret * $radix) + $b;
#   }
#   ### $ret
#   return $ret;
# }

sub pred {
  my ($self, $value) = @_;
  my $radix = $self->{'radix'};
  my $a = $value % $radix;
  if ($value = int($value/$radix)) {
    my $b = $value % $radix;
    if (! $self->{'including_repdigits'}
        && $a == $b) {
      return 0;
    }

    while ($value = int($value/$radix)) {
      if (($value % $radix) != $a) { return 0; }

      $value = int($value/$radix) || last;
      if (($value % $radix) != $b) { return 0; }
    }
  }
  return 1;
}

1;
__END__


  # if ($radix == 10) {
  #   return (length($n) <= 1
  #           || (substr($n,0,1) ne substr($n,1,1)
  #               && $n =~ /^(([0-9])[0-9])\1*\2?$/));
  # }

  # if (0 && $radix == 10) {
  #   return bless { i     => -11,
  #                  rep   => 0,
  #                  radix => $radix,
  #                }, $class;
  # } else {
  # }

# my @table =
#   grep {pred({radix=>10},$_)}
#   map {sprintf '%02d', $_}
#   10 .. 999;

  # my $rep = $self->{'rep'};
  # if (0 && $radix == 10) {
  #   my $i = ++$self->{'i'};
  #   if ($i < 0) {
  #     return $i+10;
  #   }
  #   if ($i > $#table) {
  #     $i = $self->{'i'} = 0;
  #     $self->{'rep'} = ++$rep;
  #   }
  #   my $ret = $table[$i];
  #   return $ret . (substr($ret,-2) x $rep);
  #
  # } else {

                   # limit => $radix * $radix - 1,
                   # skip  => $radix+1,  # at 11

    # if ($n >= $self->{'limit'}) {
    #   $n = ($self->{'n'} += $self->{'inc'} + 1);
    #   $self->{'limit'} = ($self->{'limit'} + $radix * $self->{'inc'});
    #   $self->{'skip'} = $radix - 1;
    #   ### limit, skip to: $n
    #   ### inc now: $self->{'inc'}
    #   ### next limit: $self->{'limit'}
    #
    # } elsif (--$self->{'skip'} < 0) {
    #   $n = ($self->{'n'} += $self->{'inc'});
    #   $self->{'skip'} = $radix - 1;
    #   ### skip to: $n
    # }
