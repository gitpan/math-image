# Copyright 2010 Kevin Ryde

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

package App::MathImage::Values::Palindromes;
use 5.004;
use strict;
use warnings;
use List::Util 'max';
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::Values';

use vars '$VERSION';
$VERSION = 35;

# uncomment this to run the ### lines
use Smart::Comments;

use constant name => __('Palindromes');
use constant description => __('Numbers which are "palindromes" reading the same backwards or forwards, like 153351.  Default is decimal, or select a radix.');

# http://www.research.att.com/~njas/sequences/A030310  # binary 1 positions
my @radix_to_oeis = (undef, # 0
                     undef, # 1
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

# palindomric primes
# 'A002385', # 10
# 'A029732', # 16
                     
sub oeis {
  my ($class_or_self) = @_;
  return $radix_to_oeis[(ref $class_or_self ? $class_or_self->{'radix'} : 10)];
}

use constant parameters => { radix => { type => 'integer',
                                        default => 10,
                                      }
                           };

sub _reverse_in_radix {
  my ($n, $radix) = @_;
  my $ret = 0;
  # ### _reverse_in_radix(): sprintf '%#X %d', $n, $n
  do {
    $ret = $ret * $radix + ($n % $radix);
  } while ($n = int($n/$radix));
  # ### ret: sprintf '%#X %d', $ret, $ret
  return $ret;
}

sub _my_cnv {
  my ($n, $radix) = @_;
  if ($radix <= 36) {
    require Math::BaseCnv;
    return Math::BaseCnv::cnv($n,10,$radix);
  } else {
    my $ret = '';
    do {
      $ret = sprintf('[%d]', $n % $radix) . $ret;
    } while ($n = int($n/$radix));
    return $ret;
  }
}

sub new {
  my ($class, %options) = @_;
  ### Emirps new()

  my $lo = $options{'lo'} || 0;
  $lo = max ($lo, 0);
  my $radix = $options{'radix'} || $class->parameters->{'radix'}->{'default'};
  if ($radix < 2) { $radix = 10; }

  $lo = max (10, $lo);

  my @digits;
  while ($lo > 0) {
    push @digits, $lo % $radix;
    $lo = int ($lo / $radix);
  }
  my $td = int((@digits+1)/2);
  splice @digits, 0, int(@digits/2);  # low half
  my $i = 0;
  while (@digits) {
    $i = $i*$radix + pop @digits;
  }
  
  return bless { i => $i,
                 radix => $radix,
               }, $class;
}

sub next {
  my ($self) = @_;
  my $i = $self->{'i'}++;
}

sub pred {
  my ($self, $n) = @_;
  my $radix = $self->{'radix'};
  my @digits;
  while ($n != 0) {
    push @digits, $n % $radix;
    $n = int ($n / $radix);
  }
  for my $i (0 .. int(@digits/2)-1) {
    if ($digits[$i] != $digits[-$i]) {
      return 0;
    }
  }
  return 1;
}

sub ith {
  my ($self, $i) = @_;
  ### Palindrome ith(): $i
  my $radix = $self->{'radix'};

  # if ($i < $radix) {
  #   return $i;
  # }
  # $i += $radix;

  my $r2 = 2*$radix;
  my $bot = 0;
  my $power = 1;
  my $j = $i;
  while ($j >= 2) {
    ### digit: $j % $radix
    $bot = $bot * $radix + ($j % $radix);
    $j = int ($j / $radix);
    $power *= $radix;
  }
  ### final: $j
  ### $power
  unless ($j) {
    $i = int ($i / $radix);
  }
  return $i * $power + $bot;
}

1;
__END__
