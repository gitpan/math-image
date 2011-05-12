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

package App::MathImage::Gtk2::Ex::QuadButton::Scroll;
use 5.008;
use strict;
use warnings;
use Gtk2 1.220;

use App::MathImage::Gtk2::Ex::QuadButton;
use App::MathImage::Gtk2::Ex::AdjustmentBits;

# uncomment this to run the ### lines
#use Smart::Comments;

our $VERSION = 56;

use Glib::Object::Subclass
  'App::MathImage::Gtk2::Ex::QuadButton',
  signals => { clicked => \&_do_clicked,
             },
  properties => [ Glib::ParamSpec->object
                  ('hadjustment',
                   (do {
                     my $str = 'Horizontal adjustment';
                     eval { require Locale::Messages;
                            Locale::Messages::dgettext('gtk20-properties',$str)
                            } || $str }),
                   'Blurb.',
                   'Gtk2::Adjustment',
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->object
                  ('vadjustment',
                   (do {
                     my $str = 'Vertical adjustment';
                     eval { require Locale::Messages;
                            Locale::Messages::dgettext('gtk20-properties',$str)
                            } || $str }),
                   'Blurb.',
                   'Gtk2::Adjustment',
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->boolean
                  ('hinverted',
                   'Horizontal inverted',
                   'Blurb.',
                   0,
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->boolean
                  ('vinverted',
                   'Vertical inverted',
                   'Blurb.',
                   0, # default
                   Glib::G_PARAM_READWRITE),
                ];

# sub INIT_INSTANCE {
#   my ($self) = @_;
# }

sub SET_PROPERTY {
  my ($self, $pspec, $newval) = @_;
  my $pname = $pspec->get_name;
  $self->{$pname} = $newval;
  ### Enum SET_PROPERTY: $pname, $newval
}

sub _do_clicked {
  my ($self, $scroll_type) = @_;
  scroll_by_type ($self->{'hadjustment'}, $self->{'vadjustment'},
                  $scroll_type,
                  $self->{'hinverted'}, $self->{'vinverted'}) = @_;

}

my %dir_to_argnum = (left  => 0,
                     right => 0,
                     up    => 1,
                     down  => 1);
my %dir_to_neg = (left  => 1,
                  right => 0,
                  up    => 1,
                  down  => 0);

# what of forward-page, jump, etc
sub scroll_by_type {
  my ($hadj, $vadj, $scroll_type, $hinv, $vinv) = @_;

  if ($scroll_type =~ /(page|step)-(up|down|left|right)/) {
    my $argnum = $dir_to_argnum{$2};
    my $adj = $_[$argnum];
    my $amount_method = "${1}_increment";
    my $add = $adj->$amount_method;
    if ($dir_to_neg{$2} ^ !!$_[3+$argnum]) {
      $add = -$add;
    }
    App::MathImage::Gtk2::Ex::AdjustmentBits::scroll_value ($adj, $add);
  }
}

1;
__END__

=for stopwords Math-Image enum ParamSpec GType pspec Enum Ryde

=head1 NAME

App::MathImage::Gtk2::Ex::QuadButton::Scroll -- group of buttons up, down, left, right

=head1 SYNOPSIS

 use App::MathImage::Gtk2::Ex::QuadButton::Scroll;
 my $qb = App::MathImage::Gtk2::Ex::QuadButton::Scroll->new;

=head1 WIDGET HIERARCHY

C<App::MathImage::Gtk2::Ex::QuadButton::Scroll> is a subclass of
C<App::MathImage::Gtk2::Ex::QuadButton>,

    Gtk2::Widget
      Gtk2::DrawingArea
        App::MathImage::Gtk2::Ex::QuadButton
          App::MathImage::Gtk2::Ex::QuadButton::Scroll

# =head1 DESCRIPTION
#
=head1 FUNCTIONS

=over 4

=item C<< $qb = App::MathImage::Gtk2::Ex::QuadButton::Scroll->new (key=>value,...) >>

Create and return a new C<QuadButton::Scroll> widget.  Optional key/value pairs set
initial properties per C<< Glib::Object->new >>.

    my $qb = App::MathImage::Gtk2::Ex::QuadButton::Scroll->new;

=back

=head1 PROPERTIES

=over 4

=item C<hadjustment> (C<Gtk2::Adjustment> object, default C<undef>)

=item C<vadjustment> (C<Gtk2::Adjustment> object, default C<undef>)

=back

=head1 SEE ALSO

L<Gtk2::Button>,
L<Gtk2::Scrollbar>

=head1 HOME PAGE

L<http://user42.tuxfamily.org/math-image/index.html>

=head1 LICENSE

Copyright 2010, 2011 Kevin Ryde

Math-Image is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 3, or (at your option) any later
version.

Math-Image is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
Math-Image.  If not, see L<http://www.gnu.org/licenses/>.

=cut
