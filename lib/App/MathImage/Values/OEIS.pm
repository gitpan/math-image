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
$VERSION = 41;

use constant name => __('OEIS');
use constant description => __('OEIS sequence, by its A-number.  There\'s code for some sequences, others look in ~/OEIS directory for a b123456.txt download (or A123456.html for just the first few values).');
use constant parameter_list
  => ({
       name    => 'anum',
       display => __('A-number'),
       width   => 8,
       type    => 'string',
       default => '10059', # A000290
      });
sub oeis {
  my ($class_or_self) = @_;
  if (ref $class_or_self) {
    return $class_or_self->{'anum'};
  }
  return undef;
}

# uncomment this to run the ### lines
#use Smart::Comments;

sub new {
  my ($class, %options) = @_;
  require App::MathImage::Values::OEIS::Catalogue;
  my $anum = $options{'anum'};
  if (! defined $anum || $anum eq '') {
    $anum = $options{'anum'} = (parameter_list)[0]->{'default'};
  }
  if (my ($class, @parameters)
      = App::MathImage::Values::OEIS::Catalogue->anum_to_class($anum)) {
    require Module::Load;
    Module::Load::load($class);
    return $class->new (%options,
                        @parameters);
  }

  require App::MathImage::Values::OEIS::File;
  return App::MathImage::Values::OEIS::File->new (%options,
                                                  anum => $anum);
}

1;
__END__

