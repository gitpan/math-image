# Copyright 2009, 2010, 2011 Kevin Ryde

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


package App::MathImage::Gtk2::Ex::Statusbar::PointerPosition;
use 5.008;
use strict;
use warnings;
use Gtk2 1.220;
use Scalar::Util 1.18 'refaddr'; # 1.18 for pure-perl refaddr() fix

use Glib::Ex::SignalIds;
use Gtk2::Ex::WidgetEvents;
use Gtk2::Ex::SyncCall 12; # v.12 workaround gtk 2.12 bug

our $VERSION = 61;

# uncomment this to run the ### lines
#use Smart::Comments;

use Glib::Object::Subclass
  'Glib::Object',
  properties => [ Glib::ParamSpec->object
                  ('widget',
                   (do {
                     my $str = 'Widget';
                     eval { require Locale::Messages;
                            Locale::Messages::dgettext('gtk20-properties',$str)
                            } || $str }),
                   'Blurb.',
                   'Gtk2::Widget',
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->object
                  ('statusbar',
                   'Statusbar widget',
                   'Blurb.',
                   'Gtk2::Statusbar',
                   Glib::G_PARAM_READWRITE),
                ],
  signals => { 'message-string' => { param_types => [ 'Gtk2::Widget',
                                                      'Glib::Int',
                                                      'Glib::Int' ],
                                     return_type => 'Glib::String',
                                     flags       => ['run-last'],
                                   },
             };

# sub INIT_INSTANCE {
#   my ($self) = @_;
# }

# sub FINALIZE_INSTANCE {
#   my ($self) = @_;
# }

sub SET_PROPERTY {
  my ($self, $pspec, $newval) = @_;
  my $pname = $pspec->get_name;

  if ($pname eq 'widget') {
    Scalar::Util::weaken ($self->{'widget'} = $newval);
  }

  $self->{'motion_ids'} = $self->{'widget'} && $self->{'statusbar'} && do {
    Scalar::Util::weaken (my $weak_self = $self);
    Glib::Ex::SignalIds->new
        ($newval,
         $newval->signal_connect (motion_notify_event => \&_do_motion_notify,
                                  \$weak_self),
         $newval->signal_connect (enter_notify_event => \&_do_motion_notify,
                                  \$weak_self),
         $newval->signal_connect (leave_notify_event => \&_do_leave_notify,
                                  \$weak_self));
  };
  $self->{'wevents'} = $self->{'motion_ids'} &&
    Gtk2::Ex::WidgetEvents->new
        ($self->{'widget'},
         ['pointer-motion-mask','enter-notify-mask']);
}

# 'enter-notify-event' signal on the widgets
# 'motion-notify-event' signal on the widgets
sub _do_motion_notify {
  my ($widget, $event, $ref_weak_self) = @_;
  ### _do_motion_notify(): "$widget"
  if (my $self = $$ref_weak_self) {
    if ($self->{'widget'} && $self->{'widget'} == $widget) {
      $self->{'x'} = $event->x;
      $self->{'x'} = $event->y;

      $self->{'sync_call_pending'} ||= do {
        Gtk2::Ex::SyncCall->sync ($widget, \&_do_synccall, $ref_weak_self);
        1;
      };
    }
  }
  return Gtk2::EVENT_PROPAGATE;
}

# 'leave-notify-event' signal on one of the widgets
sub _do_leave_notify {
  my ($widget, $event, $ref_weak_self) = @_;
  if (my $self = $$ref_weak_self) {
    undef $self->{'x'};
    undef $self->{'y'};
  }
  return Gtk2::EVENT_PROPAGATE;
}

sub _do_synccall {
  my ($widget, $ref_weak_self) = @_;
  my $self = $$ref_weak_self || return;
  $self->{'sync_call_pending'} = 0;
  my $statusbar = $self->{'statusbar'} || return;

  my $id = $statusbar->get_context_id (__PACKAGE__);
  $statusbar->pop ($id);
  if (defined $self->{'x'}) {
    my $message = $self->signal_emit ('message-string',
                                      $self->{'widget'},
                                      $self->{'x'}, $self->{'y'});
    if (defined $message) {
      $statusbar->push ($id, $message);
    }
  }
}

1;
__END__
