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

package App::MathImage::NumSeq::Palindromes;
use 5.004;
use strict;
use List::Util 'max';

use App::MathImage::NumSeq '__';
use base 'App::MathImage::NumSeq';
use App::MathImage::NumSeq::Base::Digits;

use vars '$VERSION';
$VERSION = 65;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('Palindromes');
use constant values_min => 0;
use constant description => __('Numbers which are "palindromes" reading the same backwards or forwards, like 153351.  Default is decimal, or select a radix.');
use constant parameter_list => (App::MathImage::NumSeq::Base::Digits::parameter_common_radix);

# palindomric primes
# 'A002385', # 10
# 'A029732', # 16
#
my @oeis = (undef,     # 0
            undef,     # 1
            'A006995', # 2
            'A014190', # 3
            'A014192', # 4
            'A029952', # 5
            'A029953', # 6
            'A029954', # 7
            'A029803', # 8
            'A029955', # 9
            'A002113', # 10
           );
sub oeis_anum {
  my ($class_or_self) = @_;
  my $radix = (ref $class_or_self
               ? $class_or_self->{'radix'}
               : $class_or_self->parameter_default('radix'));
  return $oeis[$radix];
}
# OEIS-Catalogue: A006995 radix=2
# OEIS-Catalogue: A014190 radix=3
# OEIS-Catalogue: A014192 radix=4
# OEIS-Catalogue: A029952 radix=5
# OEIS-Catalogue: A029953 radix=6
# OEIS-Catalogue: A029954 radix=7
# OEIS-Catalogue: A029803 radix=8
# OEIS-Catalogue: A029955 radix=9
# OEIS-Catalogue: A002113 radix=10



  # my @digits;
  # while ($lo > 0) {
  #   push @digits, $lo % $radix;
  #   $lo = int ($lo / $radix);
  # }
  # my $td = int((@digits+1)/2);
  # splice @digits, 0, int(@digits/2);  # delete low half
  # my $i = 0;
  # while (@digits) {
  #   $i = $i*$radix + pop @digits;
  # }
  # ...
sub rewind {
  my ($self) = @_;
  $self->{'i'} = 0;

  my $radix = $self->{'radix'};
  if ($radix < 2) { $radix = 10; }
  $self->{'radix'} = $radix;
}
sub next {
  my ($self) = @_;
  my $i = $self->{'i'}++;
  return ($i, $self->ith($i));
}

sub ith {
  my ($self, $i) = @_;
  ### Palindrome ith(): $i
  my $radix = $self->{'radix'};

  if ($i < 1) {
    return 0;
  }
  $i--;

  my $digits = 1;
  my $limit = $radix-1;
  my $add = 1;
  my $ret;
  for (;;) {
    if ($i < $limit) {
      ### first, no low
      $i += $add;
      $ret = int($i / $radix);
      last;
    }
    $i -= $limit;
    if ($i < $limit) {
      ### second
      $i += $add;
      $ret = $i;
      last;
    }
    $i -= $limit;
    $limit *= $radix;
    $add *= $radix;
    $digits++;
  }
  ### $limit
  ### $add
  ### $i
  ### $digits
  ### push under: $ret
  while ($digits--) {
    $ret = $ret * $radix + ($i % $radix);
    $i = int($i / $radix);
  }
  ### $ret
  return $ret;
}

sub pred {
  my ($self, $n) = @_;
  my $radix = $self->{'radix'};
  my @digits;
  while ($n) {
    push @digits, $n % $radix;
    $n = int ($n / $radix);
  }
  for my $i (0 .. int(@digits/2)-1) {
    if ($digits[$i] != $digits[-$i-1]) {
      return 0;
    }
  }
  return 1;
}

1;
__END__

# sub _my_cnv {
#   my ($n, $radix) = @_;
#   if ($radix <= 36) {
#     require Math::BaseCnv;
#     return Math::BaseCnv::cnv($n,10,$radix);
#   } else {
#     my $ret = '';
#     do {
#       $ret = sprintf('[%d]', $n % $radix) . $ret;
#     } while ($n = int($n/$radix));
#     return $ret;
#   }
# }

