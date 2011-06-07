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

package App::MathImage::NumSeq::Sequence::FractionDigits;
use 5.004;
use strict;
use List::Util 'max';

use App::MathImage::NumSeq::Base '__';
use base 'App::MathImage::NumSeq::Base::Digits';

use vars '$VERSION';
$VERSION = 59;

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
#use Smart::Comments;

my %oeis = ('1/735'  => { 10  => 'A021739',   # 1/735 decimal
                        },
           );
sub oeis_anum {
  my ($class_or_self) = @_;
  my $fraction = (ref $class_or_self
                  ? $class_or_self->{'fraction'}
                  : $class_or_self->parameter_default('fraction'));
  my $radix = (ref $class_or_self
               ? $class_or_self->{'radix'}
               : $class_or_self->parameter_default('radix'));
  return $oeis{$fraction}->{$radix};
}

# cf
# A010701 fraction=10/3 radix=10
#     - being constant digits 3,3,3,... but better ways to generate that
# 
# OeisCatalogue: A020806 fraction=1/7 radix=10
# OeisCatalogue: A068028 fraction=22/7 radix=10
# OeisCatalogue: A010680 fraction=1/11 radix=10 # and duplicated in A021015
# A021016 through A022003 fraction=1/12 to 1/999 in BuiltinCalc.pm

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

  while ($den != 0 && $num >= $radix*$den) {
    $den *= $radix;
  }
  while ($num && $num < $den) {
    $num *= $radix;
  }

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

  $num *= $radix;
  ### frac: "$num / $den"
  my $quot = int ($num / $den);
  $self->{'num'} = $num - $quot * $den;
  ### $quot
  ### rem: $self->{'num'}
  return ($self->{'i'}++, $quot);
}

1;
__END__

