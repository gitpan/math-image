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

package App::MathImage::Values::Sequence::FractionDigits;
use 5.004;
use strict;
use List::Util 'max';

use App::MathImage::Values::Base '__';
use base 'App::MathImage::Values::Base::Digits';

use vars '$VERSION';
$VERSION = 64;

use constant name => __('Fraction Digits');
use constant description => __('A given fraction number written out in binary.');
use constant parameter_list => (__PACKAGE__->SUPER::parameter_list,
                                { name    => 'fraction',
                                  display => __('Fraction'),
                                  type    => 'string',
                                  width   => 12,
                                  default => '5/29',
                                  description => __('The fraction to show, for example 5/29.  Press Return when ready to display the expression.'),
                                },
                               );

# uncomment this to run the ### lines
#use Devel::Comments;

# cf A010701 fraction=10/3 radix=10
#      - being constant digits 3,3,3,... but better ways to generate that
#
# OeisCatalogue: A020806 fraction=1/7 radix=10
# OeisCatalogue: A068028 fraction=22/7 radix=10
# OeisCatalogue: A010680 fraction=1/11 radix=10

# OeisCatalogue: A021015 fraction=1/11 radix=10  # duplicate
# OeisCatalogue: A021016 fraction=1/12 radix=10
# OeisCatalogue: A021017 fraction=1/13 radix=10
# OeisCatalogue: A021018 fraction=1/14 radix=10
# OeisCatalogue: A021019 fraction=1/15 radix=10
# OeisCatalogue: A021020 fraction=1/16 radix=10
# but A021021 is not 1/17, where is that one?
#
# Plugin/FractionDigits.pm has A021022 through A021999, 1/11 to 1/995;
# 1/11 being a duplicate, and 1/996 missing apparently
#
# OeisCatalogue: A022001 fraction=1/997 radix=10
# OeisCatalogue: A022002 fraction=1/998 radix=10
# OeisCatalogue: A022003 fraction=1/999 radix=10
#
my %oeis = (
            '1/7'   => { 10 => 'A020806' },   # 1/7 decimal
            '22/7'  => { 10 => 'A068028' },   # 22/7 decimal
            '1/11'  => { 10 => 'A010680' },   # 1/11 decimal
            '1/735' => { 10 => 'A021739' },   # 1/735 decimal
           );
sub oeis_anum {
  my ($class_or_self) = @_;
  my $fraction = (ref $class_or_self
                  ? $class_or_self->{'fraction'}
                  : $class_or_self->parameter_default('fraction'));
  my $radix = (ref $class_or_self
               ? $class_or_self->{'radix'}
               : $class_or_self->parameter_default('radix'));
  if ($radix == 10
      && $fraction =~ m{(\d+)/(\d+)}
      && $1 == 1
      && $2 >= 12 && $2 <= 999) {
    return 'A0'.($2 + 21016-12);
  }
  return $oeis{$fraction}->{$radix};
}

sub new {
  my ($class, %options) = @_;
  ### FractionDigits new()
  my $lo = $options{'lo'} || 0;
  ### $lo
  my $radix = $options{'radix'} || 2;

  my $fraction = $options{'fraction'};
  if (! defined $fraction) {
    $fraction = $class->parameter_default('fraction');
  }
  my $num = 0;  # 0/0 if unrecognised
  my $den = 0;
  ($num, $den) = ($fraction =~ m{^\s*
                                 ([.[:digit:]]+)?
                                 \s*
                                 (?:/\s*
                                   ([.[:digit:]]+)?
                                 )?
                                 \s*$}x);
  if (! defined $num) { $num = 1; }
  if (! defined $den) { $den = 1; }
  ### $num
  ### $den
  $fraction = "$num/$den";

  my $num_decimals = 0;
  my $den_decimals = 0;
  if ($num =~ m{(\d*)\.(\d+)}) {
    $num = $1 . $2;
    $num_decimals = length($2);
  }
  if ($den =~ m{(\d*)\.(\d+)}) {
    $den = $1 . $2;
    $den_decimals = length($2);
  }
  $num .= '0' x max(0, $den_decimals - $num_decimals);
  $den .= '0' x max(0, $num_decimals - $den_decimals);

  while ($den != 0 && $num >= $den) {
    $den *= $radix;
  }
  # while ($num && $num < $den) {
  #   $num *= $radix;
  # }

  ### create
  ### $num
  ### $den
  return bless { fraction => $fraction,
                 num   => $num,
                 den   => $den,
                 radix => $radix,
                 i     => 0,
               }, $class;
}
sub next {
  my ($self) = @_;

  my $num   = $self->{'num'} || return;  # num==0 exact radix frac
  my $den   = $self->{'den'} || return;  # den==0 invalid
  my $radix = $self->{'radix'};
  my $i = $self->{'i'};
  ### FractionDigits next(): "$i  $num/$den"

  ### frac: "$num / $den"
  $num *= $radix;
  my $quot = int ($num / $den);
  $self->{'num'} = $num - $quot * $den;
  ### $quot
  ### rem: $self->{'num'}
  return ($self->{'i'}++, $quot);
}

1;
__END__

