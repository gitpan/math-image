# Copyright 2010, 2011 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published
# by the Free Software Foundation; either version 3, or (at your option) any
# later version.
#
# Math-Image is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-Image.  If not, see <http://www.gnu.org/licenses/>.

package App::MathImage::Gtk2::Ex::QuadScroll::ArrowButton;
use 5.008;
use strict;
use warnings;
use Gtk2;
use Glib::Ex::SignalBits;

# uncomment this to run the ### lines
#use Smart::Comments;

our $VERSION = 45;

# priority level "gtk" treating this as widget level default, for overriding
# by application or user RC
#
Gtk2::Rc->parse_string (<<'HERE');
style "App__MathImage__Gtk2__Ex__QuadScroll__Arrow_style" {
  GtkButton::default-border = {0,0,0,0}
  GtkButton::inner-border = {0,0,0,0}
  GtkButton::image-spacing = 9
  GtkArrow::arrow-scaling = 1
  GtkWidget::focus-line-width = 0
}
class "App__MathImage__Gtk2__Ex__QuadScroll__Arrow" style:gtk "App__MathImage__Gtk2__Ex__QuadScroll__Arrow_style"
widget "*.App__MathImage__Gtk2__Ex__QuadScroll__Arrow" style:gtk "App__MathImage__Gtk2__Ex__QuadScroll__Arrow_style"
HERE

use Glib::Object::Subclass
  'Gtk2::Button',
  signals => { clicked => \&_do_clicked,
             },
  properties => [ Glib::ParamSpec->enum
                  ('arrow-type',
                   'Arrow type',
                   'Blurb.',
                   'Gtk2::ArrowType',
                   'none',
                   Glib::G_PARAM_READWRITE),
                ];

sub INIT_INSTANCE {
  my ($self) = @_;
  $self->set (relief => 'none');
  $self->can_focus (0);

  my $child = Gtk2::Arrow->new ('none', 'none');
  $child->set_name ('App__MathImage__Gtk2__Ex__QuadScroll__Arrow');
  $child->show;
  $self->add ($child);
}

sub GET_PROPERTY {
  my ($self, $pspec) = @_;
  my $pname = $pspec->get_name;
  if ($pname eq 'arrow_type') {
    my $child = $self->get_child || return 'none';
    return $child->get ('arrow-type');
  }
  return $self->{$pname};
}

sub SET_PROPERTY {
  my ($self, $pspec, $newval) = @_;
  my $pname = $pspec->get_name;
  ### QuadScroll-Arrow SET_PROPERTY: $pname, $newval

  if ($pname eq 'arrow_type') {
    my $child = $self->get_child || return;
    $child->set ($newval, 'none');
  } else {
    $self->{$pname} = $newval;
  }
}

sub _do_clicked {
  my ($self) = @_;
  ### QuadScroll-Arrow _do_clicked()
  my $parent = $self->get_parent || return;
  my $arrow_type = $self->get('arrow_type');
  $parent->signal_emit ('change-value',
                        (Gtk2->get_current_event->get_state & 'control-mask'
                         ? 'page' : 'step')
                        . '-'
                        . $arrow_type);
}

1;
__END__
