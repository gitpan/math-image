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


package App::MathImage::Gtk2::OeisEntry;
use 5.008;
use strict;
use warnings;
use Gtk2;
use POSIX ();
use List::Util 'max';
use Locale::TextDomain 1.19 ('App-MathImage');

use App::MathImage::Gtk2::Ex::ArrowButton;

# uncomment this to run the ### lines
#use Smart::Comments;

our $VERSION = 52;

Gtk2::Rc->parse_string (<<'HERE');
style "App__MathImage__Gtk2__OeisEntry_style" {
  xthickness = 0
  ythickness = 0
}
widget_class "*App__MathImage__Gtk2__OeisEntry*GtkAspectFrame" style:application "App__MathImage__Gtk2__OeisEntry_style"
HERE

use Glib::Object::Subclass
  'Gtk2::HBox',
  signals => {
              # size_request  => \&do_size_request,
              # size_allocate => \&do_size_allocate,
              activate => { param_types => [ ] },
             },
  properties => [ Glib::ParamSpec->string
                  ('text',
                   __('A-number'),
                   'Blurb.',
                   'A000290',
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->int
                  ('width-chars',
                   __('Width in characters'),
                   'Blurb.',
                   -1, POSIX::INT_MAX(),
                   -1,
                   Glib::G_PARAM_READWRITE),

                ];

sub INIT_INSTANCE {
  my ($self) = @_;
  ### OeisSpinButton INIT_INSTANCE()

  # $self->set_spacing (0);

  my $entry = $self->{'entry'} = Gtk2::Entry->new;
  $entry->set_text ('A000290');
  $entry->set_width_chars (7);
  $entry->signal_connect (activate => \&_do_entry_activate);
  $entry->show;
  # $self->add ($entry);
  $self->pack_start ($entry, 1,1,0);

  $self->{'right'} = my $aspect = Gtk2::AspectFrame->new ('', .5,.5, .5, 0);
  $aspect->set_label (undef);
  $aspect->set_shadow_type ('none');

  # $aspect->set_border_width (0);
  ### aspect border_width: $aspect->get_border_width
  # ### xt: $aspect->get_style->xthickness

  my $vbox = Gtk2::VBox->new (0, 0);
  $self->pack_start ($vbox, 0,0,0);
  # $self->add ($vbox);
  #  $aspect->add ($vbox);

  my $h = $entry->size_request->height;
  $vbox->set_size_request ($h/2, -1);

  # $self->pack_start ($vbox, 0,0,0);
  # my $group = $self->{'size_group'} = Gtk2::SizeGroup->new ('vertical');
  # $group->add_widget ($entry);
  # $group->add_widget ($vbox);

  foreach my $dir ('up','down') {
    my $button = App::MathImage::Gtk2::Ex::ArrowButton->new
      (arrow_type => $dir);
    $button->{'direction'} = $dir;
    $button->signal_connect (clicked => \&_do_button_clicked);
    ### xt: $button->get_style->xthickness
    $vbox->pack_start ($button, 1,1,0);
  }
  $vbox->show_all;
}

sub GET_PROPERTY {
  my ($self, $pspec) = @_;
  my $pname = $pspec->get_name;
  if ($pname eq 'text' || $pname eq 'width_chars') {
    return $self->{'entry'}->get_property($pname);
  }
  return $self->{$pname};
}

sub SET_PROPERTY {
  my ($self, $pspec, $newval) = @_;
  my $pname = $pspec->get_name;
  if ($pname eq 'text' || $pname eq 'width_chars') {
    return $self->{'entry'}->set_property ($pname, $newval);
  }
  return $self->{$pname};
}

# 'size-request' class handler
sub do_size_request {
  my ($self, $req) = @_;
  $self->{'right'}->size_request;
  my $entry_req = $self->{'entry'}->size_request;
  my $h = $entry_req->height;
  $req->width ($entry_req->width + int($h/2));
  $req->height ($h);
}

# 'size-allocate' class closure
#
# called by our parent to give us actual allocated space -- pass this down
# to the child, less the border width
# 
sub do_size_allocate {
  my ($self, $alloc) = @_;
  ### do_size_allocate()
  $self->signal_chain_from_overridden ($alloc);

  my $entry = $self->{'entry'};
  my $right = $self->{'right'};
  $right->set_size_request ($alloc->height / 2, -1);

  # my $border_width  = $self->get_border_width;
  # my $x = $alloc->x + $border_width;
  # my $y = $alloc->y + $border_width;
  # my $width = max (1, $alloc->width  - 2*$border_width);
  # my $height = max (1, $alloc->height - 2*$border_width);
  # 
  # my $entry_width = max (1, $width - int($height/2));
  # my $right_width = max (1, $width - $entry_width);
  # $entry->size_allocate (Gtk2::Gdk::Rectangle->new ($x, $y, $entry_width, $height));
  # $right->size_allocate (Gtk2::Gdk::Rectangle->new ($x + $entry_width, $y, $right_width, $height));
  # ### $entry_width
  # ### $right_width
  # 
  # ### entry now: $entry->allocation->width, $entry->allocation->height
  # ### right now: $right->allocation->width, $right->allocation->height
}

sub _do_entry_activate {
  my ($entry) = @_;
  my $self = $entry->get_ancestor (__PACKAGE__) || return;
  $self->activate;
}

sub _do_button_clicked {
  my ($button) = @_;
  my $self = $button->get_ancestor (__PACKAGE__) || return;
  my $entry = $self->{'entry'};

  my $method = $button->{'direction'} eq 'up' ? 'anum_after' : 'anum_before';
  require App::MathImage::NumSeq::OeisCatalogue;
  my $next_anum = App::MathImage::NumSeq::OeisCatalogue->$method
    ($entry->get_text);
  if (! defined $next_anum) {
    $next_anum = App::MathImage::NumSeq::OeisCatalogue->anum_last;
  }
  if (defined $next_anum) {
    $entry->set_text ($next_anum);
    $self->activate;
  }
}

sub activate {
  my ($self) = @_;
  $self->signal_emit ('activate');
}

              # change_value => \&_do_change_value,
              #  # value_changed => \&_do_value_changed,
              #  button_press_event => \&_do_button_press_event,
# sub new {
#   my ($class, $adj, $climb_rate, $digits) = @_;
#   ### OeisSpinButton new()
#   return $class->SUPER::new (adjustment => $adj,
#                              climb_rate => $climb_rate,
#                              digits     => $digits);
# }

#   my $new_value = $self->get_value;
#   if ($new_value != $old_value) {

#   my $ret = $self->signal_chain_from_overridden (@_);
#   my $new_value = $self->get_value;
#   if ($new_value != $old_value) {
#     if ($new_value > $old_value) {
#       $new_value = App::MathImage::NumSeq::OeisCatalogue->num_after($new_value-1);
#     } else {
#       $new_value = App::MathImage::NumSeq::OeisCatalogue->num_before($new_value+1);
#     }
#     $self->set_value ($new_value);
#   }
#   return $ret;
# }

# sub _do_change_value {
#   my ($self, $scroll_type) = @_;
#   ### _do_change_value(): $scroll_type
# 
#   my $adj = $self->get_adjustment;
#   my $amount;
#   if ($scroll_type =~ /^(step|page)/) {
#     my $method = $1.'_increment';
#     $amount = $adj->$method;
#     ### $amount
# 
#     $method = ($scroll_type =~ /(backward|down|left)$/
#                ? 'anum_before' : 'anum_after');
#     ### $method
# 
#     my $value = $self->get_value;
#     while ($amount-- > 0) {
#       if (defined (my $next = App::MathImage::NumSeq::OeisCatalogue->$method($value))) {
#         $value = $next;
#       } else {
#         last;
#       }
#     }
#     ### $value
#     $self->set_value($value);
# 
#   } elsif ($scroll_type eq 'start') {
#     ### start: App::MathImage::NumSeq::OeisCatalogue->num_first
#     $self->set_value (App::MathImage::NumSeq::OeisCatalogue->num_first);
# 
#   } elsif ($scroll_type eq 'end') {
#     ### start: App::MathImage::NumSeq::OeisCatalogue->num_last
#     $self->set_value (App::MathImage::NumSeq::OeisCatalogue->num_last);
# 
#   } else {
#     ### chain
#     shift->signal_chain_from_overridden (@_);
#   }
# }

# sub _do_value_changed {
#   my ($self) = @_;
#   $self->signal_chain_from_overridden;
# 
#use Glib::Ex::ObjectBits;
#   Glib::Ex::ObjectBits::set_property_maybe ($self, tooltip_text => 
# }

1;
__END__
