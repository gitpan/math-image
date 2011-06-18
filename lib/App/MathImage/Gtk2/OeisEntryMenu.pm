# Copyright 2011 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-Image is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-Image.  If not, see <http://www.gnu.org/licenses/>.

package App::MathImage::Gtk2::OeisEntryMenu;
use 5.008;
use strict;
use warnings;
use Gtk2;
use Locale::TextDomain ('App-MathImage');

our $VERSION = 60;

use Glib::Object::Subclass
  'Gtk2::Menu',
  properties => [ Glib::ParamSpec->string
                  ('anum',
                   'OEIS A-number',
                   'Blurb.',
                   '', # default
                   Glib::G_PARAM_READWRITE),
                ];

sub INIT_INSTANCE {
  my ($self) = @_;

  # avoid selecting Entry too easily
  $self->append (Gtk2::SeparatorMenuItem->new);
  {
    my $item = $self->{'download'}
      = Gtk2::MenuItem->new_with_mnemonic (__('_Download'));
    $self->append ($item);
    $item->signal_connect (activate => \&_do_download);
    $item->show;
  }
}

sub SET_PROPERTY {
  my ($self, $pspec, $newval) = @_;
  my $pname = $pspec->get_name;
  $self->{$pname} = $newval;  # per default GET_PROPERTY
  _update_sensitive($self);
}

sub _update_sensitive {
  my ($self) = @_;
  my $anum = $self->{'anum'};
  $self->{'download'}->set_sensitive (!! $anum);
}

sub _do_download {
  my ($item) = @_;
  my $self = $item->get_toplevel;
  my $anum = $self->{'anum'} || return;

}

sub popup_from_entry {
  my ($self, $event, $oeis_entry) = @_;
  if (! ref $self) {
    $self = $self->new;
  }
  if ($oeis_entry) {
    $self->set (anum => $oeis_entry->get('text'),
                screen => $oeis_entry->get_screen);
  }
  $self->popup (undef, undef, undef, undef, $event->button, $event->time);
  return $self;
}

1;
__END__

=for stopwords OEIS entrybox OeisEntry Ryde

=head1 NAME

App::MathImage::Gtk2::OeisEntryMenu -- menu of things in an OEIS entrybox

=for test_synopsis my ($event, $oeis_entry)

=head1 SYNOPSIS

 use App::MathImage::OeisEntryMenu;
 my $menu = App::MathImage::OeisEntryMenu->new;

 App::MathImage::OeisEntryMenu->popup_from_entry ($event, $oeis_entry);

=head1 WIDGET HIERARCHY

C<App::MathImage::OeisEntryMenu> is a subclass of C<Gtk::Menu>,

    Gtk2::Widget
      Gtk2::Container
        Gtk2::MenuShell
          Gtk2::Menu
            App::MathImage::OeisEntryMenu

=head1 DESCRIPTION

An C<App::MathImage::OeisEntryMenu> displays a little menu for an OeisEntry
box.

    +----------+
    +----------+
    +----------+
    | Download |
    +----------+

=head1 FUNCTIONS

=over 4

=item C<< App::MathImage::OeisEntryMenu->new (key=>value,...) >>

Create and return a new C<App::MathImage::OeisEntryMenu> object.  Optional
key/value pairs set initial properties as per C<< Glib::Object->new >>.

=back

=head1 PROPERTIES

=over 4

=item C<anum> (string, default C<undef>)

The A-number to act on in the menu.  Normally this is set at the time the
menu is popped up.  Changing it while popped up works, but could confuse the
user.

=back

=head1 SEE ALSO

L<App::MathImage::Gtk2::OeisEntry>, L<Gtk2::Menu>

=head1 HOME PAGE

L<http://user42.tuxfamily.org/math-image/index.html>

=head1 LICENSE

Copyright 2010, 2011 Kevin Ryde

Math-Image is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation; either version 3, or (at your option) any later
version.

Math-Image is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
Math-Image.  If not, see L<http://www.gnu.org/licenses/>.

=cut
