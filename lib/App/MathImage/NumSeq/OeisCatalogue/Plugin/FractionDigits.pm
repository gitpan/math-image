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

package App::MathImage::NumSeq::OeisCatalogue::Plugin::FractionDigits;
use 5.004;
use strict;
use List::Util 'min', 'max'; # FIXME: 5.6 only, maybe

use vars '@ISA';
use App::MathImage::NumSeq::OeisCatalogue::Base;
@ISA = ('App::MathImage::NumSeq::OeisCatalogue::Base');

use vars '$VERSION';
$VERSION = 54;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant num_first => 21016;
use constant num_last  => 22003;

sub anum_after {
  my ($class, $anum) = @_;
  (my $num = $anum) =~ s/^A0*//g;
  $num ||= 0;
  if ($num >= $class->num_last) {
    return undef;
  }
  return sprintf 'A%06d', max ($num+1, $class->num_first);
}
sub anum_before {
  my ($class, $anum) = @_;
  (my $num = $anum) =~ s/^A0*//g;
  $num ||= 0;
  if ($num <= $class->num_first) {
    return undef;
  }
  return sprintf 'A%06d', min ($num-1, $class->num_last);
}

sub anum_to_info {
  my ($class, $anum) = @_;
  ### Catalogue-BuiltinCalc num_to_info(): @_

  # App::MathImage::NumSeq::Sequence::FractionDigits
  # fraction=1/k radix=10 for k=11 to 999 is anum=21004+k,
  # being A021015 through A022003, though 1/11 is also A010680 and prefer
  # that one (in BuiltinTable)

  my $num = $anum;
  if ($num =~ s/^A0*//g) {
    if ($num >= $class->num_first && $num <= $class->num_last) {
      return $class->make_info($num);
    }
  }
  return undef;
}

my @info_array;
sub info_arrayref {
  my ($class) = @_;
  if (! @info_array) {
    @info_array = map {$class->make_info($_)}
      $class->num_first .. $class->num_last;
    ### made info_arrayref: @info_array
  }
  return \@info_array;
}

sub make_info {
  my ($class, $num) = @_;
  ### make_info(): $num
  return { anum  => sprintf('A%06d', $num),
           class => 'App::MathImage::NumSeq::Sequence::FractionDigits',
           parameters_hashref => { fraction => '1/'.($num-21004) } };
}

1;
__END__

