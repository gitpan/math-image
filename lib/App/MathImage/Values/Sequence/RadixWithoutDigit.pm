# Copyright 2010, 2011 Kevin Ryde

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

package App::MathImage::Values::Sequence::RadixWithoutDigit;
use 5.004;
use strict;

use App::MathImage::Values::Base '__';
use base 'App::MathImage::Values::Sequence';
use App::MathImage::Values::Base::Digits;

use vars '$VERSION';
$VERSION = 63;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant name => __('Without chosen digit');
use constant description => __('The integers which don\'t have a given digit when written out in the given radix.  Digit -1 means the highest digit, ie. radix-1.');

use constant parameter_list =>
  (App::MathImage::Values::Base::Digits::parameter_common_radix(),
   { name    => 'digit',
     type    => 'integer',
     display => __('Digit'),
     default => -1,
     minimum => -1,
     width   => 2,
     description => __('Digit to exclude.  Default -1 means the highest digit, radix-1.'),
   });

my %oeis = (3 => { 0 => 'A032924', # base 3 no 0
                   1 => 'A005823', # base 3 no 1
                   2 => 'A005836', # base 3 no 2
                 },
            4 => { 0 => 'A023705', # base 4 no 0
                   1 => 'A023709', # base 4 no 1
                   2 => 'A023713', # base 4 no 2
                   3 => 'A023717', # base 4 no 3
                 },
            5 => { 0 => 'A023721', # base 5 no 0
                   1 => 'A023725', # base 5 no 1
                   2 => 'A023729', # base 5 no 2
                   3 => 'A023733', # base 5 no 3
                   4 => 'A023737', # base 5 no 4
                 },
           );
sub oeis_anum {
  my ($class_or_self) = @_;
  my $radix = (ref $class_or_self
               ? $class_or_self->{'radix'}
               : $class_or_self->parameter_default('radix'));
  my $digit = (ref $class_or_self
               ? $class_or_self->{'digit'}
               : $class_or_self->parameter_default('digit'));
  if ($digit == -1) {
    $digit = $radix-1;
  }
  return $oeis{$radix}->{$digit};
}
# OeisCatalogue: A032924 radix=3 digit=0  # base 3 no 0
# OeisCatalogue: A005823 radix=3 digit=1  # base 3 no 1
# in TernaryWithout2 ... # OeisCatalogue: A005836 radix=3 digit=2  # base 3 no 2
                
# OeisCatalogue: A023705 radix=4 digit=0  # base 4 no 0
# OeisCatalogue: A023709 radix=4 digit=1  # base 4 no 1
# OeisCatalogue: A023713 radix=4 digit=2  # base 4 no 2
# in Base4without3 ... # OeisCatalogue: A023717 radix=4 digit=3  # base 4 no 3
                
# OeisCatalogue: A023721 radix=5 digit=0  # base 5 no 0
# OeisCatalogue: A023725 radix=5 digit=1  # base 5 no 1
# OeisCatalogue: A023729 radix=5 digit=2  # base 5 no 2
# OeisCatalogue: A023733 radix=5 digit=3  # base 5 no 3
# OeisCatalogue: A023737 radix=5 digit=4  # base 5 no 4

sub new {
  my ($class, %options) = @_;

  my $radix = $options{'radix'} || $class->parameter_default('radix');
  my $digit = $options{'digit'};
  if (! defined $digit) { $digit = $class->parameter_default('digit'); }
  if ($digit == -1) { $digit = $radix - 1; }
  $digit = $digit % $radix;
  my $lo = $options{'lo'} || 0;
  my $n = abs($lo);

  my $i = 0;
  if ($radix == 2) {
    if ($digit == 1) {
      my $n = 1;
      while ($n < $lo) { 
        $i++;
      }
    }
  } else {
    # look at the $radix digits of $n, build $i by treating as $radix-1,
    # increment any $digit to go to the next without that
    my $power = 1;
    while ($n) {
      my $rem = $n % $radix;
      if ($rem >= $digit) {
        $n++;
      } else {
        $i += $rem * $power;
      }
      $n = int ($n / $radix);
      $power *= ($radix-1);
    }

    if ($lo < 0) {
      $i = -$i;
      if ($n == $lo) {
        $i--;
      }
    }
  }
  $class->SUPER::new(radix => $radix,
                     digit => $digit);
}
sub rewind {
  my ($self) = @_;
  $self->{'ith'} = 0;
}
sub next {
  my ($self) = @_;
  my $i = $self->{'ith'}++;
  return ($i, $self->ith($i));
}

# without 0
#     1-9 1-9 ... 1-9 for len digits
#     each is 9^len many
#     start at i = 9^1 + ... + 9^(len-1)
#                = 9^0 + 9^1 + ... + 9^(len-1)  - 1
#                = (9^len - 1)/8 - 1
#                = (9^len - 1 - 8)/8
#                = (9^len - 9)/8
#     8*i + 1 = 9^level
#
#     add sentinel 1*9^len, so
#     from = i - (9^len - 9)/8 + 9^len
#          = i + (- 9^len + 9)/8 + 9^len
#          = i + (- 9^len + 9 + 8*9^len)/8
#          = i + (7*9^len + 9) / 8
#
#     and which is then a high digit 2*9^len too big
#
sub ith {
  my ($self, $i) = @_;
  ### RadixWithoutDigit ith(): $i
  my $radix = $self->{'radix'};
  my $digit = $self->{'digit'};
  if ($radix == 2) {
    if ($digit == 0) {
      return (2 << $i) - 1;
    } else {
      return undef;
    }
  }

  if ($i == $i-1) {
    return $i;  # don't loop forever if $i is +infinity
  }

  my $r1 = $radix - 1;
  # if ($i < $r1) {
  #   return $i + ($i >= $digit);
  # }
  my $r2 = $radix - 2;
  ### $radix
  ### $r1
  ### $r2

  my $value = 0;
  if ($digit == 0) {
    my $len = 1;
    while (($r1**$len - $r1) / $r2 <= $i) {
      $len++;
    }
    $len--;
    ### $len
    ### base: ($r1**$len - $r1) / $r2
    ### sentinel: $r1**$len
    ### adj add: $r1**$len - ($r1**$len - $r1) / $r2
    ### adj formula: (($r2-1)*$r1**$len + $r1) / $r2

    ### assert: $i >= ($r1 ** $len - $r1) / $r2
    ### assert: $i < ($r1 ** $len - $r1) / $r2 + $r1 ** $len

    $i += (($r2-1)*$r1**$len + $r1) / $r2;
    $value = -2 * $radix**$len;
    ### i remainder: $i
    ### $value

    ### assert: $i >= $r1 ** $len
    ### assert: $i < 2 * $r1 ** $len
  }

  # $i converted to radix-1 digits, built back up as radix
  my $power = 1;
  while ($i > 0) {
    my $d = $i % $r1;
    $i = int($i/$r1);
    ### $value
    ### $d
    ### $power
    if ($d >= $digit) {
      $d++;
      ### inc to d: $d
    }
    $value += $power * $d;
    $power *= $radix;
  }
  ### stop at i: $i
  $value += $power * $i;

  ### $value
  return $value;

  # my $digit = 1;
  # my $x = $i;
  # while ($x) {
  #   ### x mod $radix: $x%$radix
  #   if (($x % $radix) == $digit) {
  #     ### add: $digit
  #     $i += $digit;
  #     $x++;
  #   }
  #   $x = int($x/$radix);
  #   $digit *= $radix;
  # }
  # return (($self->{'i'} = $i),
  #         1);
}

sub pred {
  my ($self, $value) = @_;
  my $radix = $self->{'radix'};
  my $digit = $self->{'digit'};
  if ($digit == 0 && $value == 0) {
    return 0;
  }
  while ($value) {
    if (($value % $radix) == $digit) {
      return 0;
    }
    $value = int ($value / $radix);
  }
  return 1;
}

1;
__END__
