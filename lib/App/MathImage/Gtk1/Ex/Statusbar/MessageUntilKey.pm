# Copyright 2008, 2009, 2010, 2011 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published
# by the Free Software Foundation; either version 3, or (at your option) any
# later version.
#
# Math-Image is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-Image.  If not, see <http://www.gnu.org/licenses/>.

package App::MathImage::Gtk1::Ex::Statusbar::MessageUntilKey;
use 5.004;
use strict;

use vars '$VERSION';
$VERSION = 76;

# uncomment this to run the ### lines
#use Devel::Comments;

### MessageUntilKey loads ...

sub message {
  my ($class, $statusbar, $str) = @_;
  ### MessageUntilKey: $str
  $statusbar->{(__PACKAGE__)} ||= $class->_new($statusbar);
  my $id = $statusbar->get_context_id(__PACKAGE__);
  $statusbar->pop ($id);
  $statusbar->push ($id, $str);
}

# The alternative would be a single KeySnooper object and emission hook, and
# have it look through a list of statusbars with messages, maybe held in a
# Tie::RefHash::Weak.  But normally there'll be just one or two statusbars,
# so aim for small and simple.
#
sub _new {
  my ($class, $statusbar) = @_;

  require Scalar::Util;
  require App::MathImage::Gtk1::Ex::KeySnooper;
  Scalar::Util::weaken (my $weak_statusbar = $statusbar);
  return bless
    { snooper => App::MathImage::Gtk1::Ex::KeySnooper->new (\&_do_event, \$weak_statusbar),
    }, $class;


  # emission_id => Gtk::Widget->signal_add_emission_hook
  # (button_press_event => \&_do_button_hook, \$weak_statusbar)
}

# sub DESTROY {
#   my ($self) = @_;
#   Gtk::Widget->signal_remove_emission_hook
#       (button_press_event => $self->{'emission_id'});
# }

sub remove {
  my ($class_or_self, $statusbar) = @_;
  ### MessageUntilKey remove: $statusbar->{(__PACKAGE__)}

  delete $statusbar->{(__PACKAGE__)} || return;
  my $id = $statusbar->get_context_id(__PACKAGE__);
  $statusbar->pop ($id);
}

# KeySnooper handler, and called from button below
sub _do_event {
  my ($widget, $event, $ref_weak_statusbar) = @_;
  ### MessageUntilKey _do_event: $event->type

  # the snooper should be destroyed together with statusbar, but the button
  # hook isn't, so check $ref_weak_statusbar hasn't gone away
  #
  # $statusbar->get_display() is the default display if not under a toplevel
  # (it's never NULL or undef), which means events there will clear
  # unparented statusbars.  Not sure if that's ideal, but close enough for
  # now.

  if ($event->type eq 'key-press' || $event->type eq 'button-press') {
    if (my $statusbar = $$ref_weak_statusbar) {
      if (! $widget->can('get_display')
          || $widget->get_display == $statusbar->get_display) {
        # call through object to allow for subclassing
        if (my $self = $statusbar->{(__PACKAGE__)}) {
          $self->remove ($statusbar);
        }
      }
    }
  }
  return 0; # EVENT_PROPAGATE
}

# 'button-press-event' signal emission hook
sub _do_button_hook {
  my ($invocation_hint, $parameters, $ref_weak_statusbar) = @_;
  my ($widget, $event) = @$parameters;
  _do_event ($widget, $event, $ref_weak_statusbar);
  return 1; # stay connected, remove() does any disconnect
}

1;
__END__
