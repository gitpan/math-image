# Copyright 2011, 2012 Kevin Ryde

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


# Wx::SpinCtrl and Wx::SpinButton are integer-only


package App::MathImage::Wx::Params::Float;
use 5.004;
use strict;
use POSIX ();
use Wx;
use List::Util 'min', 'max';

use base 'Wx::TextCtrl';
our $VERSION = 102;

# uncomment this to run the ### lines
#use Smart::Comments;


sub new {
  my ($class, $parent, $info) = @_;
  ### Params-Float new(): "$parent", $info

    my $min = $info->{'minimum'};
    if (! defined $min) { $min = POSIX::DBL_MIN; }
    my $max = $info->{'maximum'};
    if (! defined $max) { $max = POSIX::DBL_MAX; }

    # my $page_increment = $newval->{'page_increment'};
    # if (! defined $page_increment) { $page_increment = 1; }
    # my $step_increment = $newval->{'step_increment'};
    # if (! defined $step_increment) { $step_increment = $page_increment / 10; }

  # my $display = ($info->{'display'} || $info->{'name'});
  my $self = $class->SUPER::new ($parent,
                                 Wx::wxID_ANY(),
                                 $info->{'default'} || '0', # initial value
                                 Wx::wxDefaultPosition(),
                                 Wx::Size->new (10*($info->{'width'} || 5),
                                                -1),
                                 Wx::wxTE_PROCESS_ENTER());  # style
  Wx::Event::EVT_TEXT_ENTER ($self, $self, 'OnTextChange');
  Wx::Event::EVT_MOUSEWHEEL ($self, 'OnMouseWheel');

  $self->{'info'} = $info;

  return $self;
}

sub OnTextChange {
  my ($self) = @_;

  if (my $callback = $self->{'callback'}) {
    &$callback($self);
  }
}

sub OnMouseWheel {
  my ($self, $event) = @_;
  ### IsPageScroll: $event->IsPageScroll

  my $value = $self->GetValue;
  $value += ($event->ControlDown ? 1 : 0.1)
    * $event->GetWheelRotation / $event->GetWheelDelta;
  my $info = $self->{'info'};
  if (defined (my $maximum = $info->{'maximum'})) {
    $value = min ($value, $maximum);
  }
  if (defined (my $minimum = $info->{'minimum'})) {
    $value = max ($value, $minimum);
  }
  if (defined (my $decimals = $info->{'decimals'})) {
    $value = sprintf '%.*f', $decimals, $value;
  }
  $self->SetValue ($value);
  $self->OnTextChange;
}

1;
__END__
