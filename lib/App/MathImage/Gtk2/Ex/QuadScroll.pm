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

package App::MathImage::Gtk2::Ex::QuadScroll;
use 5.008;
use strict;
use warnings;
use Gtk2;
use List::Util 'min', 'max';

use App::MathImage::Gtk2::Ex::AdjustmentBits;

# uncomment this to run the ### lines
#use Smart::Comments;

our $VERSION = 44;

use Glib::Object::Subclass
  'Gtk2::Table',
  signals => { # size_allocate => \&_do_size_allocate,
              scroll_event => \&App::MathImage::Gtk2::Ex::AdjustmentBits::scroll_widget_event_vh,

              set_scroll_adjustments =>
              { param_types => ['Gtk2::Adjustment',
                                'Gtk2::Adjustment'],
                return_type => undef,
                class_closure => \&_do_set_scroll_adjustments },

              'change-value' =>
              { param_types => [ 'Gtk2::ScrollType'],
                return_type => undef,
                class_closure => \&_do_change_value,
                flags => ['run-first','action'] },
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

                  Glib::ParamSpec->double
                  ('xalign',
                   (do {
                     my $str = 'Horizontal alignment';
                     eval { require Locale::Messages;
                            Locale::Messages::dgettext('gtk20-properties',$str)
                            } || $str }),
                   'Blurb.',
                   0, 1.0, # min,max
                   0.5,    # default
                   Glib::G_PARAM_READWRITE),

                  Glib::ParamSpec->double
                  ('yalign',
                   (do {
                     my $str = 'Vertical alignment';
                     eval { require Locale::Messages;
                            Locale::Messages::dgettext('gtk20-properties',$str)
                            } || $str }),
                   'Blurb.',
                   0, 1.0, # min,max
                   0.5,    # default
                   Glib::G_PARAM_READWRITE),
                ];

# priority level "gtk" treating this as widget level default, for overriding
# by application or user RC
Gtk2::Rc->parse_string (<<'HERE');
binding "App__MathImage__Gtk2__Ex__QuadScroll_keys" {
  bind "Up"          { "change-value" (step-up) }
  bind "Down"        { "change-value" (step-down) }
  bind "<Ctrl>Up"    { "change-value" (page-up) }
  bind "<Ctrl>Down"  { "change-value" (page-down) }
  bind "Left"        { "change-value" (step-left) }
  bind "Right"       { "change-value" (step-right) }
  bind "<Ctrl>Left"  { "change-value" (page-left) }
  bind "<Ctrl>Right" { "change-value" (page-right) }
  bind "Page_Up"     { "change-value" (page-up) }
  bind "Page_Down"   { "change-value" (page-down) }
}
class "App__MathImage__Gtk2__Ex__QuadScroll" binding:gtk "App__MathImage__Gtk2__Ex__QuadScroll_keys"
HERE

use constant _DIRECTIONS => ('up', 'down', 'left', 'right');
my %dir_to_x = (left  => 0,
                right => 0,
                up   => 1,
                down => 1);
my %dir_to_y = (left  => 0,
                right => 1,
                up   => 0,
                down => 1);

sub INIT_INSTANCE {
  my ($self) = @_;
  ### QuadScroll INIT_INSTANCE()
  $self->can_focus (1);

  require App::MathImage::Gtk2::Ex::QuadScroll::ArrowButton;
  foreach my $dir (_DIRECTIONS) {
    my $arrow = $self->{$dir}
      = App::MathImage::Gtk2::Ex::QuadScroll::ArrowButton->new
        (arrow_type => $dir,
         visible => 1);
    my $x = $dir_to_x{$dir};
    my $y = $dir_to_y{$dir};
    $self->attach ($arrow, $x,$x+1, $y,$y+1,
                   ['fill','shrink'],['fill','shrink'],0,0);
  }
  $self->set_size_request (4,4);
}

# 'set-scroll-adjustments' class closure
sub _do_set_scroll_adjustments {
  my ($self, $hadj, $vadj) = @_;
  $self->set (hadjustment => $hadj,
              vadjustment => $vadj);
}

my %dir_to_neg = (left  => 1,
                  right => 0,
                  up    => 1,
                  down  => 0);

sub _do_change_value {
  my ($self, $scrolltype) = @_;
  scroll_by_type ($self->{'hadjustment'},
                  $self->{'vadjustment'},
                  $scrolltype,
                  $self->{'hinvert'},
                  $self->{'vinvert'});

  # my $adj = $self->{"${vh}adjustment"} || return;
  # if ($scrolltype =~ /(page|step)-(up|down|left|right)/) {
  #   my $amount_method = "${1}_increment";
  #   my $add = $adj->$amount_method;
  #   if ($dir_to_neg{$2} ^ !!$self->{"${vh}inverted"}) {
  #     $add = -$add;
  #   }
  #   App::MathImage::Gtk2::Ex::AdjustmentBits::scroll_value ($adj, $add);
  # }
}

my %dir_to_arg = (left  => 0,
                  right => 0,
                  up    => 1,
                  down  => 1);

# what of forward-page, jump, etc
sub scroll_by_type {
  my ($hadj, $vadj, $scroll_type, $hinv, $vinv) = @_;

  if ($scroll_type =~ /(page|step)-(up|down|left|right)/) {
    my $arg = $dir_to_arg{$2};
    my $adj = $_[$arg];
    my $amount_method = "${1}_increment";
    my $add = $adj->$amount_method;
    if ($dir_to_neg{$2} ^ !!$_[3+$arg]) {
      $add = -$add;
    }
    App::MathImage::Gtk2::Ex::AdjustmentBits::scroll_value ($adj, $add);
  }
}



1;
__END__

=for stopwords Math-Image enum ParamSpec GType pspec Enum Ryde

=head1 NAME

App::MathImage::Gtk2::Ex::QuadScroll -- group of buttons up, down, left, right

=head1 SYNOPSIS

 use App::MathImage::Gtk2::Ex::QuadScroll;
 my $qb = App::MathImage::Gtk2::Ex::QuadScroll->new;

=head1 WIDGET HIERARCHY

C<App::MathImage::Gtk2::Ex::QuadScroll> is a subclass of
C<Gtk2::DrawingArea>, but don't rely on more than C<Gtk2::Widget> for now.

    Gtk2::Widget
      Gtk2::DrawingArea
        App::MathImage::Gtk2::Ex::QuadScroll

# =head1 DESCRIPTION
# 
=head1 FUNCTIONS

=over 4

=item C<< $qb = App::MathImage::Gtk2::Ex::QuadScroll->new (key=>value,...) >>

Create and return a new QuadScroll object.  Optional key/value pairs set
initial properties per C<< Glib::Object->new >>.

    my $qb = App::MathImage::Gtk2::Ex::QuadScroll->new;

=back

# =head1 PROPERTIES
# 
# =over 4
# 
# =item C<combobox> (C<Gtk2::ComboBox> object, default C<undef>)
# 
# =back

=head1 SEE ALSO

L<Gtk2::Button>,
L<Gtk2::Arrow>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-image/index.html

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
