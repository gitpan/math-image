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


# go to no extension when combobox nothing selected ...


package App::MathImage::Gtk2::OeisSpinButton;
use 5.008;
use strict;
use warnings;
use Gtk2;

use App::MathImage::NumSeq::OeisCatalogue;

# uncomment this to run the ### lines
#use Smart::Comments;

our $VERSION = 49;

use Glib::Object::Subclass
  'Gtk2::SpinButton',
  signals => { change_value => \&_do_change_value,
               # value_changed => \&_do_value_changed,
               button_press_event => \&_do_button_press_event,
             };

sub new {
  my ($class, $adj, $climb_rate, $digits) = @_;
  ### OeisSpinButton new()
  return $class->SUPER::new (adjustment => $adj,
                             climb_rate => $climb_rate,
                             digits     => $digits);
}

sub INIT_INSTANCE {
  my ($self) = @_;
  ### OeisSpinButton INIT_INSTANCE()
}

sub _do_button_press_event {
  my $self = shift;
  my $old_value = $self->get_value;
  my $ret = $self->signal_chain_from_overridden (@_);
  my $new_value = $self->get_value;
  if ($new_value != $old_value) {
    if ($new_value > $old_value) {
      $new_value = App::MathImage::NumSeq::OeisCatalogue->num_after($new_value-1);
    } else {
      $new_value = App::MathImage::NumSeq::OeisCatalogue->num_before($new_value+1);
    }
    $self->set_value ($new_value);
  }
  return $ret;
}

sub _do_change_value {
  my ($self, $scroll_type) = @_;
  ### _do_change_value(): $scroll_type

  my $adj = $self->get_adjustment;
  my $amount;
  if ($scroll_type =~ /^(step|page)/) {
    my $method = $1.'_increment';
    $amount = $adj->$method;
    ### $amount

    $method = ($scroll_type =~ /(backward|down|left)$/
               ? 'num_before' : 'num_after');
    ### $method

    my $value = $self->get_value;
    while ($amount-- > 0) {
      if (defined (my $next = App::MathImage::NumSeq::OeisCatalogue->$method($value))) {
        $value = $next;
      } else {
        last;
      }
    }
    ### $value
    $self->set_value($value);

  } elsif ($scroll_type eq 'start') {
    ### start: App::MathImage::NumSeq::OeisCatalogue->num_first
    $self->set_value (App::MathImage::NumSeq::OeisCatalogue->num_first);

  } elsif ($scroll_type eq 'end') {
    ### start: App::MathImage::NumSeq::OeisCatalogue->num_last
    $self->set_value (App::MathImage::NumSeq::OeisCatalogue->num_last);

  } else {
    ### chain
    shift->signal_chain_from_overridden (@_);
  }
}

# sub _do_value_changed {
#   my ($self) = @_;
#   $self->signal_chain_from_overridden;
# 
#use Glib::Ex::ObjectBits;
#   Glib::Ex::ObjectBits::set_property_maybe ($self, tooltip_text => 
# }

1;
__END__
