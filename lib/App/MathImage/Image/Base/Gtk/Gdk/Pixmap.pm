# Copyright 2010, 2011 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-Image is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-Image.  If not, see <http://www.gnu.org/licenses/>.


package App::MathImage::Image::Base::Gtk::Gdk::Pixmap;
use 5.008;
use strict;
use warnings;
use Carp;

use vars '$VERSION','@ISA';
$VERSION = 75;

use App::MathImage::Image::Base::Gtk::Gdk::Drawable;
@ISA = ('App::MathImage::Image::Base::Gtk::Gdk::Drawable');

# uncomment this to run the ### lines
#use Devel::Comments;


sub new {
  my ($class, %params) = @_;
  ### Gdk-Pixmap new: \%params

  # $obj->new(...) means make a copy, with some extra settings
  if (ref $class) {
    my $self = $class;
    # $class = ref $class;
    if (! defined $params{'-pixmap'}) {
      # $self->get('-gc') creates and retains a gc.  Doing that seems better
      # than letting _drawable_clone_to_pixmap() create and destroy one,
      # though if there was one already in Gtk::GC with the right depth
      # then could just use that.
      $params{'-pixmap'} = _drawable_clone_to_pixmap ($self->get('-pixmap'),
                                                      $self->get('-gc'));
    }
    # inherit everything else, but don't share gc
    %params = (%$self,
               -gc => undef,
               %params);
  }

  if (exists $params{'-pixmap'}) {
    $params{'-drawable'} = delete $params{'-pixmap'};
  }

  if (! exists $params{'-drawable'}) {
    ### create new pixmap

    my $for_drawable = delete $params{'-for_drawable'};
    my $for_widget = delete $params{'-for_widget'};
    my $depth = delete $params{'-depth'};
    ### for_widget: "$for_widget"

    $for_drawable
      ||= ($for_widget && $for_widget->window)
        || Gtk::Gdk::Window->new_foreign(Gtk::Gdk->ROOT_WINDOW());

    if (! exists $params{'-colormap'}) {
      if (my $colormap = (($for_drawable && $for_drawable->get_colormap)
                          || ($for_widget && $for_widget->get_colormap))) {
        $params{'-colormap'} = $colormap;
      }

      # can't check depth ?
      # if (my $default_colormap
      #     = ($for_drawable && $for_drawable->get_colormap)
      #     || ($for_widget && $for_widget->get_colormap)) {
      #   if (! defined $depth
      #       || $depth == $default_colormap->get_visual->depth) {
      #     $params{'-colormap'} = $default_colormap;
      #   }
      # }
    }
    if (! defined $params{'-colormap'}) {
      delete $params{'-colormap'};
    }

    if (! defined $depth) {
      # depth from colormap ?
      # if ($params{'-colormap'}) {
      #   $depth = $params{'-colormap'}->get_visual->depth;
      # } els

      if ($for_drawable) {
        $depth = $for_drawable->get_depth;
      } else {
        $depth = -1;
      }
    }
    ### $depth

    $params{'-drawable'} = Gtk::Gdk::Pixmap->new ($for_drawable,
                                                  delete $params{'-width'},
                                                  delete $params{'-height'},
                                                  $depth);
    # -colormap is applied in Drawable new() doing set()
  }

  return $class->SUPER::new (%params);
}

sub new_from_image {
  my $self = shift;
  my $new_class = shift;
  if ($new_class eq __PACKAGE__
      || $new_class eq 'Image::Base::Gtk::Gdk::Drawable') {
    return bless $self->new(@_), $new_class;
  }
  return $self->SUPER::new_from_image ($new_class, @_);
}

# $pixmap is a Gtk::Gdk::Pixmap
# create and return a clone of it
# $gc is used to copy the contents, or a temporary gc used if $gc not given
#
sub _drawable_clone_to_pixmap {
  my ($drawable, $gc) = @_;
  my ($height, $width) = $drawable->get_size;
  my $new_pixmap = Gtk::Gdk::Pixmap->new ($drawable, $width, $height, -1);

  if (my $colormap = $drawable->get_colormap) {
    $new_pixmap->set_colormap ($colormap);
  }

  # gtk_gc_get() only uses colormap to determine the screen ...
  # is there any value trying for a shared one?
  # it'd share with someone else using an empty values hash presumably
  # for similar copying
  $gc ||= Gtk::GC->get ($drawable->get_depth,
                         $drawable->get_colormap);
  # $gc ||= Gtk::Gdk::GC->new ($drawable);

  $new_pixmap->draw_drawable ($gc, $drawable, 0,0, 0,0, $width,$height);
  return $new_pixmap;
}

1;
__END__

=for stopwords Ryde Gtk Gdk Pixmaps pixmap colormap ie toplevel Image-Base-Gtk

=head1 NAME

App::MathImage::Image::Base::Gtk::Gdk::Pixmap -- draw into a Gdk pixmap

=for test_synopsis my $win

=head1 SYNOPSIS

 use App::MathImage::Image::Base::Gtk::Gdk::Pixmap;
 my $image = App::MathImage::Image::Base::Gtk::Gdk::Pixmap->new
                 (-width => 10,
                  -height => 10,
                  -for_drawable => $win);
 $image->line (0,0, 99,99, '#FF00FF');
 $image->rectangle (10,10, 20,15, 'white');

=head1 CLASS HIERARCHY

C<App::MathImage::Image::Base::Gtk::Gdk::Pixmap> is a subclass of
C<Image::Base::Gtk::Gdk::Drawable>,

    Image::Base
      Image::Base::Gtk::Gdk::Drawable
        App::MathImage::Image::Base::Gtk::Gdk::Pixmap

=head1 DESCRIPTION

C<App::MathImage::Image::Base::Gtk::Gdk::Pixmap> extends C<Image::Base> to create and draw
into Gdk Pixmaps.  There's no file load or save, just drawing operations.

The drawing is done by the C<Image::Base::Gtk::Gdk::Drawable> base class.
This class adds some pixmap creation help.

=head1 FUNCTIONS

See L<Image::Base::Gtk::Gdk::Drawable/FUNCTIONS> and
L<Image::Base/FUNCTIONS> for the behaviour inherited from the superclasses.

=over 4

=item C<$image = App::MathImage::Image::Base::Gtk::Gdk::Pixmap-E<gt>new (key=E<gt>value,...)>

Create and return a new pixmap image object.  It can be pointed at an
existing pixmap,

    $image = App::MathImage::Image::Base::Gtk::Gdk::Pixmap->new
                 (-pixmap => $pixmap);

Or a new pixmap created,

    $image = App::MathImage::Image::Base::Gtk::Gdk::Pixmap->new
                 (-width    => 10,
                  -height   => 10);

A pixmap requires a size and, depth (bits per pixel) and usually a colormap
for allocating colours.  The default is the screen depth and colormap, or
desired settings can be applied with

    -depth    =>  integer bits per pixel
    -colormap =>  Gtk::Gdk::Colormap object or undef

If just C<-colormap> is given then the depth is taken from it.  If C<-depth>
is given and it's not the screen's default depth then there's no default
colormap (as it would be wrong), which happens when creating a bitmap,

    $image = App::MathImage::Image::Base::Gtk::Gdk::Pixmap->new
                 (-width   => 10,
                  -height  => 10,
                  -depth   => 1);  # bitmap, no colormap

The following further helper options can create a pixmap for use with a
widget, window, or another pixmap,

    -for_drawable  => Gtk::Gdk::Drawable object (win or pixmap)
    -for_widget    => Gtk::Widget object

These targets give a colormap and depth.  C<-colormap> and/or C<-depth> can
be given to override if desired.

If a widget plays tricks with its window colormap or depth then it might
only have the right settings after realized (ie. has created its window).

=item C<$new_image = $image-E<gt>new (key=E<gt>value,...)>

Create and return a copy of C<$image>.  The underlying pixmap is cloned by
creating a new one and copying contents to it.

=back

=head1 ATTRIBUTES

=over

=item C<-width> (integer, read-only)

=item C<-height> (integer, read-only)

The size of a pixmap cannot be changed once created.

=item C<-pixmap> (C<Gtk::Gdk::Pixmap> object)

The target pixmap.  C<-drawable> and C<-pixmap> access the same attribute.

=back

=head1 SEE ALSO

L<Image::Base>,
L<Image::Base::Gtk::Gdk::Drawable>,
L<Image::Base::Gtk::Gdk::Window>,
L<Gtk::reference>

=cut
