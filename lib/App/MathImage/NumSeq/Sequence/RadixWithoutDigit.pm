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

package App::MathImage::NumSeq::Sequence::RadixWithoutDigit;
use 5.004;
use strict;

use App::MathImage::NumSeq::Base '__';
use base 'App::MathImage::NumSeq::Sequence';
use App::MathImage::NumSeq::Base::Digits;

use vars '$VERSION';
$VERSION = 59;

use constant name => __('Without chosen digit');
use constant description => __('The integers which don\'t have a given digit when written out in the given radix.  Digit -1 means the highest digit, ie. radix-1.');

use constant parameter_list =>
  (App::MathImage::NumSeq::Base::Digits::parameter_common_radix(),
   { name    => 'digit',
     type    => 'integer',
     display => __('Digit'),
     default => -1,
     minimum => -1,
     width   => 4,
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
                   4 => 'A023733', # base 5 no 3
                   5 => 'A023737', # base 5 no 4
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
# OeisCatalogue: A023733 radix=5 digit=4  # base 5 no 3
# OeisCatalogue: A023737 radix=5 digit=5  # base 5 no 4

# uncomment this to run the ### lines
#use Smart::Comments;

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
  return bless { i => $i,
                 radix => $radix,
                 digit => $digit,
               }, $class;
}
sub rewind {
  my ($self) = @_;
  $self->{'ith'} = 0;
}
sub next {
  my ($self) = @_;
  return $self->ith ($self->{'i'}++);
}
sub ith {
  my ($self, $i) = @_;
  ### RadixWithoutDigit ith(): $i
  # $i converted to radix-1 digits, built back up as radix
  my $radix = $self->{'radix'};
  my $digit = $self->{'digit'};
  if ($radix == 2) {
    if ($digit == 0) {
      return ($self->{'ith'}++, (2 << $i) - 1);
    } else {
      return;
    }
  }
  if ($i == 0) {
    return ($self->{'ith'}++, ($digit ? 0 : 1));
  }
  my $ret = 0;
  my $power = 1;
  my $r1 = $radix - 1;
  do {
    my $d = $i % $r1;
    $i = int($i/$r1);
    ### $ret
    ### $d
    ### $power
    if ($d >= $digit && ($i || $digit)) {
      $d++;
      ### inc: $d
    }
    $ret += $power * $d;
    $power *= $radix;
  } while ($i);

  ### $ret
  return ($self->{'ith'}++, $ret);

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
  my ($self, $n) = @_;
  my $radix = $self->{'radix'};
  my $digit = $self->{'digit'};
  while ($n) {
    if (($n % $radix) == $digit) {
      return 0;
    }
    $n = int ($n / $radix);
  }
  return 1;
}

1;
__END__
