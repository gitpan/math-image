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

package App::MathImage::Values::OEIS;
use 5.004;
use strict;
use warnings;
use Carp;
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::Values';

use vars '$VERSION';
$VERSION = 44;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('OEIS');
use constant description => __('OEIS sequence, by its A-number.  There\'s code for some sequences, others look in ~/OEIS directory for a b123456.txt download (or A123456.html for just the first few values).');
use constant parameter_list =>
  ({
    name    => 'oeis_number',
    display => __('A-number'),
    width   => 8,
    type    => 'string',
    default => 290, # Squares
   });
sub oeis {
  my ($class_or_self) = @_;
  if (ref $class_or_self) {
    return $class_or_self->{'oeis_number'};
  }
  return undef;
}

sub new {
  my ($class, %options) = @_;
  ### Values-OEIS: @_

  require App::MathImage::Values::OEIS::Catalogue;
  my $oeis_number = $options{'oeis_number'};
  if (defined $oeis_number) {
    $oeis_number =~ s/^A0*//;
  } else {
    $oeis_number = (parameter_list)[0]->{'default'};
  }
  ### $oeis_number

  my $info = App::MathImage::Values::OEIS::Catalogue->num_to_info($oeis_number)
    || croak 'Unknown OEIS sequence ',$oeis_number;
  ### $info

  my $numseq_class = $info->{'class'};
  my $parameters_href = $info->{'parameters_href'};
  require Module::Load;
  Module::Load::load($numseq_class);
  return $numseq_class->new (%options, %{$info->{'parameters_hashref'}});
}

1;
__END__

