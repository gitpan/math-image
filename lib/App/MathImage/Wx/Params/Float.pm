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


package App::MathImage::Wx::Params::Float;
use 5.004;
use strict;
use POSIX ();
use Wx;

use base 'Wx::SpinCtrl';
our $VERSION = 80;

# uncomment this to run the ### lines
#use Devel::Comments;


sub new {
  my ($class, $parent, $info) = @_;
  ### Params-Float new(): "$parent", $info

  my $minimum = $info->{'minimum'};
  if (! defined $minimum) { $minimum = POSIX::INT_MIN(); }
  my $maximum = $info->{'maximum'};
  if (! defined $maximum) { $maximum = POSIX::INT_MAX(); }

    # my $min = $newval->{'minimum'};
    # if (! defined $min) { $min = POSIX::DBL_MIN; }
    # my $max = $newval->{'maximum'};
    # if (! defined $max) { $max = POSIX::DBL_MAX; }

    # my $page_increment = $newval->{'page_increment'};
    # if (! defined $page_increment) { $page_increment = 1; }
    # my $step_increment = $newval->{'step_increment'};
    # if (! defined $step_increment) { $step_increment = $page_increment / 10; }

  # digits => ($newval->{'decimals'} || 8));

  # my $display = ($info->{'display'} || $info->{'name'});
  my $self = $class->SUPER::new ($parent,
                                 Wx::wxID_ANY(),
                                 $info->{'default'}, # initial value
                                 Wx::wxDefaultPosition(),
                                 Wx::Size->new (10*($info->{'width'} || 5),
                                                -1),
                                 Wx::wxSP_ARROW_KEYS(),  # style
                                 $minimum,
                                 $maximum);
  Wx::Event::EVT_SPINCTRL ($self, $self, 'OnSpinChange');
  return $self;
}

sub OnSpinChange {
  my ($self) = @_;
}

1;
__END__
