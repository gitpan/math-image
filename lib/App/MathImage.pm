# Copyright 2010 Kevin Ryde

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

package App::MathImage;
use 5.004;
use strict;
use warnings;
use Carp;
use List::Util qw(min max);

# uncomment this to run the ### lines
#use Smart::Comments;

use vars '$VERSION';
$VERSION = 11;

sub _hopt {
  my ($self, $hashname, $key, $value) = @_;
  if (defined $self->{$hashname}->{$key}) {
    die "Already got \"$key\" option \"$self->{$hashname}->{$key}\"\n";
  }
  $self->{$hashname}->{$key} = $value;
}

sub getopt_long_specifications {
  my ($self) = @_;
  return
    ('display=s' =>
     sub { my ($name, $value) = @_;
           _hopt($self, 'other_options', 'display', $value);  },

     'values=s'  =>
     sub { my ($name, $value) = @_;
           _hopt($self,'gen_options','values', "$value"); },
     'primes'   => sub{_hopt($self,'gen_options','values', 'primes'); },
     'twin'     => sub{_hopt($self,'gen_options','values', 'twin_primes'); },
     'twin1'    => sub{_hopt($self,'gen_options','values', 'twin_primes_1'); },
     'twin2'    => sub{_hopt($self,'gen_options','values', 'twin_primes_2'); },
     'semi-primes|semiprimes' =>
     sub { _hopt($self,'gen_options','values', 'semi_primes'); },
     'semi-primes-odd|semiprimes-odd|semip-odd' =>
     sub { _hopt($self,'gen_options','values', 'semi_primes_odd'); },

     'squares'    => sub { _hopt($self,'gen_options','values', 'squares');  },
     'pronic'     => sub { _hopt($self,'gen_options','values', 'pronic');  },
     'triangular' => sub { _hopt($self,'gen_options','values', 'triangular'); },
     'pentagonal' => sub { _hopt($self,'gen_options','values', 'polygonal');
                           _hopt($self,'gen_options','polygonal', 5);  },
     'cubes'      => sub { _hopt($self,'gen_options','values', 'cubes');  },
     'tetrahedral' => sub { _hopt($self,'gen_options','values', 'tetrahedral');},
     'perrin'     => sub { _hopt($self,'gen_options','values', 'perrin');  },
     'padovan'    => sub { _hopt($self,'gen_options','values', 'padovan');  },
     'fibonacci'  => sub { _hopt($self,'gen_options','values', 'fibonacci');  },
     'fraction-bits=s' =>
     sub { my ($name, $value) = @_;
           $value =~ m{^\d+/\d+$}
             or die "Invalid fraction: $value";
           _hopt($self,'gen_options','values',   'fraction_bits');
           _hopt($self,'gen_options','fraction', $value);
         },
     'expression=s' =>
     sub { my ($name, $value) = @_;
           ### $value
           $value = "$value";
           my $tree = Math::Symbolic->parse_from_string($value);
           if (! defined $tree) {
             die "invalid expression for Math::Symbolic";
           }
           _hopt($self,'gen_options','values',     'expression');
           _hopt($self,'gen_options','expression', $value);
         },
     'polygonal=i' =>
     sub { my ($name, $value) = @_;
           _hopt($self,'gen_options','values',    'polygonal');
           _hopt($self,'gen_options','polygonal', "$value"); },
     'pi'      =>sub { _hopt($self,'gen_options','values', 'pi_bits');  },
     'ln2'     => sub{_hopt($self,'gen_options','values', 'ln2_bits');  },
     'odd'     => sub{_hopt($self,'gen_options','values', 'odd');  },
     'even'    => sub{_hopt($self,'gen_options','values', 'even');  },
     'all'     => sub{_hopt($self,'gen_options','values', 'all');  },
     'lines'   => sub{_hopt($self,'gen_options','values', 'lines');  },
     # these undocumented yet ...
     'aronson' => sub{_hopt($self,'gen_options','values', 'aronson');  },
     'prime-quadratic-euler' => sub{
       _hopt($self,'gen_options','values', 'prime_quadratic_euler');
       _hopt($self,'gen_options','prime_quadratic', 'primes');
     },

     'path=s'  => sub{my ($name, $value) = @_;
                      _hopt($self,'gen_options','path', "$value");  },
     'ulam'     =>
     sub { _hopt($self,'gen_options','path', 'SquareSpiral');  },
     'square-spiral' =>
     sub { _hopt($self,'gen_options','path', 'SquareSpiral'); },
     'hex'      =>
     sub { _hopt($self,'gen_options','path', 'HexSpiral'); },
     'hex-skewed' =>
     sub { _hopt($self,'gen_options','path', 'HexSpiralSkewed');},
     'sacks'    =>
     sub { _hopt($self,'gen_options','path', 'SacksSpiral');  },
     'vogel-floret' =>
     sub { _hopt($self,'gen_options','path', 'VogelFloret');  },
     'diamond'  =>
     sub { _hopt($self,'gen_options','path', 'DiamondSpiral');  },
     'pyramid|pyramid-sides' =>
     sub { _hopt($self,'gen_options','path', 'PyramidSides');  },
     'pyramid-rows'  =>
     sub { _hopt($self,'gen_options','path', 'PyramidRows');  },
     'knight-spiral' => sub{_hopt($self,'gen_options','path','KnightSpiral')},
     'corner'    => sub{_hopt($self,'gen_options','path', 'Corner');  },
     'diagonals' => sub{_hopt($self,'gen_options','path', 'Diagonals');  },
     'rows'      => sub{_hopt($self,'gen_options','path', 'Rows');  },
     'columns'   => sub{_hopt($self,'gen_options','path', 'Columns');  },

     'scale=i'  => sub{my ($name, $value) = @_;
                       _hopt($self,'gen_options','scale', "$value");  },

     'show=s'   => sub{my ($name, $value) = @_;
                       _hopt($self, 'gui_options', 'show', "$value");  },
     'root'     => sub{_hopt($self, 'gui_options', 'show', 'root');  },
     'root-x11-protocol' =>
     sub{ _hopt ($self, 'gui_options', 'show', 'root_x11_protocol');  },
     'root-gtk' =>
     sub{ _hopt ($self, 'gui_options', 'show', 'root_gtk');  },
     'xpm'      => sub{_hopt($self, 'gui_options', 'show', 'xpm');  },
     'png'      => sub{_hopt($self, 'gui_options', 'show', 'png');  },
     'png-gd'   => sub{_hopt($self, 'gui_options', 'show', 'png-gd');  },
     'png-pngwriter' => sub{_hopt($self, 'gui_options', 'show', 'png-pngwriter');  },
     'text'     => sub{_hopt($self, 'gui_options', 'show', 'text'); },
     'text-numbers' => sub{_hopt($self, 'gui_options', 'show', 'text-numbers'); },
     'text-list' => sub{_hopt($self, 'gui_options', 'show', 'text-list'); },
     'help|?' => sub{_hopt($self, 'gui_options', 'show', 'help'); },
     'version' => sub{_hopt($self, 'gui_options', 'show', 'version'); },

     'random'   => sub {
       require App::MathImage::Generator;
       my @random = App::MathImage::Generator->random_options;
       while (my ($key, $value) = splice @random,0,2) {
         if ($key eq 'path' || $key eq 'values') {
           _hopt($self,'gen_options', $key, $value);
         } else {
           $self->{'gen_defaults'}->{$key} = $value;
         }
       }
     },

     'fullscreen' => sub{_hopt($self, 'gui_options', 'fullscreen', 1);  },
     'size=s' => sub {
       my ($name, $value) = @_;
       my ($width, $height) = split /x/, $value;
       _hopt($self,'gen_options','width', $width);
       _hopt($self,'gen_options','height', $height || $width);
     },
     'size-scale=s' => sub {
       my ($name, $value) = @_;
       my ($width, $height) = split /x/, $value;
       _hopt($self,'gen_options','width', $width);
       _hopt($self,'gen_options','height', $height || $width);
       $self->{'gen_options'}->{'width_in_scale'} = 1;
       $self->{'gen_options'}->{'height_in_scale'} = 1;
     },
     'foreground=s'  => sub {
       my ($name, $value) = @_;
       _hopt ($self, 'gen_options','foreground',$value);
     },
     'background=s'  => sub {
       my ($name, $value) = @_;
       _hopt ($self, 'gen_options','background',$value);
     },
     'verbose:1'      => \$self->{'verbose'},
    );
}

sub show_method_version {
  my ($self) = @_;
  print "math-image version ",$self->VERSION,"\n";
  return 0;
}

sub show_method_help {
  my ($self) = @_;
  print <<'HERE';
math-image [--options]
Path:
  --ulam         Ulam's square spiral of primes
  --sacks        Sacks spiral
  --vogel        Vogel floret
  --pyramid      rows 1  2,3,4  5,6,7,8,9  etc
  --diagonal     diagonal rows 1  2,3  4,5,6   7,8,9,10  etc
  --corner
  --rows         across in rows
  --columns      downwards in columns
  --diamond
  --path=WHAT
Values:
  --squares      squares 1,4,9,16,25,...
  --pronic       pronic numbers x*(x+1)  2,6,12,20,30,...
  --triangular   triangle numbers x*(x+1)/2  1,3,6,10,15,21,...
  --polygonal=K  the K-sided polygon numbers
  --cubes        cubes 1,8,27,64,125,...
  --tetrahedral  numbers 1,4,10,20,35,56,...
  --perrin       sequence 3,0,2,3,2,5,5,7,10,12,17,...
  --padovan      sequence 1,1,2,2,3,4,5,7,9,12,...
  --primes       primes 2,3,5,7,11,13,...
  --twin         twin primes 3,5,7, 11,13, 17,19,...
  --twin1        first of each twin prime 3,5,11,17,...
  --twin2        second of each twin prime 5,7,13,19,...
  --fibonacci    fibonacci numbers 1,1,2,3,5,8,13,21,...
  --fraction=NUM/DEN   base-2 of given fraction
  --ln2          bits of natural log(2)
  --all          all integers 1,2,3,...
  --odd          odd numbers 1,3,5,7,9,...
  --even         even numbers 2,4,6,8,10,...
  --lines        draw lines showing the path, instead of values
  --values=WHAT
Other:
  --help         print this help
  --version      print program version number
HERE
  return 0;
}

sub new {
  my $class = shift;
  my $self = bless { gen_options  => {},
                     gen_defaults => { values     => 'primes',
                                       path       => 'SquareSpiral',
                                       foreground => 'white',
                                       background => 'black',
                                     },
                     gui_options  => {},
                     other_options => {},
                     verbose => 0,
                     @_ }, $class;
}

sub command_line {
  my ($self) = @_;
  ref $self or $self = $self->new;

  require Getopt::Long;
  Getopt::Long::Configure ('no_ignore_case');
  Getopt::Long::Configure ('pass_through');
  Getopt::Long::GetOptions ($self->getopt_long_specifications) or return 1;
  ### @ARGV

  my $gui_options = $self->{'gui_options'};
  my $gen_options = $self->{'gen_options'};
  my $other_options = $self->{'other_options'};

  # defaults
  %$gui_options = (show => 'window',
                   %$gui_options);
  ### gui_options: $gui_options
  my $show = $gui_options->{'show'};

  ### command line: $gen_options
  %$gen_options = (%{$self->{'gen_defaults'}},
                   %$gen_options);
  ### gen_options: $gen_options
  if (! defined $gen_options->{'scale'}) {
    $gen_options->{'scale'}
      = ($show eq 'text'
         ? ($gen_options->{'values'} eq 'lines' ? 2 : 1)
         : ($gen_options->{'values'} eq 'lines' ? 5 : 3));
  }
  if (defined $gen_options->{'width'} && delete $gen_options->{'width_in_scale'}) {
    $gen_options->{'width'} *= $gen_options->{'scale'};
  }
  if ($gen_options->{'height'} && delete $gen_options->{'height_in_scale'}) {
    $gen_options->{'height'} *= $gen_options->{'scale'};
  }
  ### gen_options now: $gen_options

  my $x11_error;
  if ($show eq 'root') {
    ## root, try x11 protocol
    if (eval { $self->x11_protocol_object }) {
      $show = 'root_x11_protocol'
    } else {
      $x11_error = $@;
    }
  }

  if ($show eq 'window' || $show eq 'root' || $show eq 'root_gtk') {
    ## window or root, try gtk
    if (defined $other_options->{'display'}) {
      unshift @ARGV, '--display', $other_options->{'display'};
    }
    ### Gtk2 init
    ### @ARGV
    unless (eval { require Gtk2 } && Gtk2->init_check) {
      if ($show eq 'root') {
        die "Cannot use X11::Protocol nor Gtk2 for root:\n",$x11_error;
      } else {
        die "Cannot initialize Gtk2\n$@\n";
      }
    }
    if ($show eq 'root') {
      # gtk initialized successfully, use it for the root
      $show = 'root_gtk';
    }
  }
  if (@ARGV) { die "Unrecognised option(s): ",join(' ',@ARGV); }

  (my $show_method = "show_method_$show") =~ tr/-/_/;
  my $coderef = $self->can($show_method)
    || die "Unrecognised show option: $show";
  return $self->$coderef;
}

sub show_method_text {
  my ($self) = @_;
  $self->term_size;
  #   $gen_options->{'foreground'} = '*';
  #   $gen_options->{'background'} = ' ';
  #   @image_options = (-cindex => { $gen_options->{'foreground'} => '*',
  #                                  $gen_options->{'background'} => ' ' });
  _output_image ($self, 'Image::Base::Text');
}
sub show_method_xpm {
  my ($self) = @_;
  _output_image ($self, 'Image::Xpm');
}
sub show_method_png {
  my ($self) = @_;
  if (eval { require Image::Base::GD }) {
    $self->show_method_png_gd;
  } elsif (eval { require Image::Base::PNGwriter }) {
    $self->show_method_png_pngwriter;
  } else {
    die 'Neither Image::Base::GD nor Image::Base::PNGwriter available to write png';
  }
}
sub show_method_png_pngwriter {
  my ($self) = @_;
  binmode (\*STDOUT) or die;
  _output_image ($self, 'Image::Base::PNGwriter');
}
sub show_method_png_gd {
  my ($self) = @_;
  binmode (\*STDOUT) or die;
  _output_image ($self, 'Image::Base::GD');
}
sub _output_image {
  my ($self, $image_class) = @_;
  my $gen_options = $self->{'gen_options'};
  if (! defined $gen_options->{'width'}) {
    $gen_options->{'width'} = 200;
    $gen_options->{'height'} = 200;
  }
  require Module::Load;
  Module::Load::load ($image_class);

  my $image = $image_class->new
    (-width  => $gen_options->{'width'},
     -height => $gen_options->{'height'});
  { my $gen = $self->make_generator;
    $gen->draw_Image ($image); }

  require App::MathImage::Image::Base::Other;
  App::MathImage::Image::Base::Other::save_fh ($image, \*STDOUT);
  return 0;
}

sub show_method_window {
  my ($self) = @_;

  my $gen_options = $self->{'gen_options'};
  require App::MathImage::Gtk2::Main;
  my $toplevel = App::MathImage::Gtk2::Main->new
    (fullscreen => delete $self->{'gui_options'}->{'fullscreen'});
  $toplevel->signal_connect (destroy => sub{Gtk2->main_quit });

  my $draw = $toplevel->{'draw'};
  if (defined (my $width = delete $gen_options->{'width'})) {
    my $height = delete $gen_options->{'height'};
    require Gtk2::Ex::Units;
    Gtk2::Ex::Units::set_default_size_with_subsizes
        ($toplevel, [ $draw, $width, $height ]);
  } else {
    $toplevel->set_default_size
      (map {$_*0.8} $toplevel->get_root_window->get_size);
  }
  ### draw set: $gen_options
  my $fg_color = Gtk2::Gdk::Color->parse (delete $gen_options->{'foreground'});
  my $bg_color = Gtk2::Gdk::Color->parse (delete $gen_options->{'background'});
  $draw->modify_fg ('normal', $fg_color);
  $draw->modify_bg ('normal', $bg_color);
  $draw->set (%$gen_options);

  $toplevel->show;
  Gtk2->main;
  return 0;
}

sub show_method_root_gtk {
  my ($self) = @_;
  ### root using Gtk

  my $gen_options = $self->{'gen_options'};
  my $rootwin = Gtk2::Gdk->get_default_root_window;
  ($gen_options->{'width'}, $gen_options->{'height'}) = $rootwin->get_size;
  my $gen = $self->make_generator;
  require Image::Base::Gtk2::Gdk::Pixmap;
  my $image = Image::Base::Gtk2::Gdk::Pixmap->new
    (-for_window => $rootwin,
     -width  => $gen_options->{'width'},
     -height => $gen_options->{'height'});
  $gen->draw_Image ($image);

  $rootwin->set_back_pixmap ($image->get('-pixmap'));
  $rootwin->clear;
  $rootwin->get_display->flush;
  return 0;
}

sub x11_protocol_object {
  my ($self) = @_;
  return ($self->{'X'} ||= do {
    my $display = (defined $self->{'other_options'}->{'display'}
                   ? $self->{'other_options'}->{'display'}
                   : defined $ENV{'DISPLAY'} ? $ENV{'DISPLAY'}
                   : die "No --display or \$DISPLAY given\n");
    require X11::Protocol;
    X11::Protocol->new ($display)
    });
}

use constant XA_PIXMAP => 20;  # pre-defined atom

sub show_method_root_x11_protocol {
  my ($self) = @_;
  my $X = $self->x11_protocol_object;
  my $rootwin = $X->{'root'};
  ### $rootwin;

  my $gen_options = $self->{'gen_options'};
  my $width  = $gen_options->{'width'}  = $X->{'width_in_pixels'};
  my $height = $gen_options->{'height'} = $X->{'height_in_pixels'};
  my $colormap = $X->{'default_colormap'};

  my $pixmap;
  my $want_save = my $root_visual_dynamic
    = _X_visual_is_dynamic($X, $X->{'root_visual'});
  {
    require Image::Base::X11::Protocol::Window;
    my $image_rootwin = Image::Base::X11::Protocol::Window->new
      (-X            => $X,
       -width        => $width,
       -height       => $height,
       -window       => $rootwin,
       -colormap     => $colormap);

    require Image::Base::X11::Protocol::Pixmap;
    my $image_pixmap = Image::Base::X11::Protocol::Pixmap->new
      (-X            => $X,
       -width        => $width,
       -height       => $height,
       -colormap     => $colormap,
       -for_drawable => $rootwin);
    $pixmap = $image_pixmap->get('-pixmap');
    ### $pixmap

    require App::MathImage::Image::Base::Multiplex;
    my $image = App::MathImage::Image::Base::Multiplex->new
      (-images => [ $image_pixmap, $image_rootwin ]);

    my $gen = $self->make_generator;
    $gen->draw_Image ($image);

    ### _image_pixmap_any_allocated_colours: _image_pixmap_any_allocated_colours($image_pixmap)
    $want_save &&= _image_pixmap_any_allocated_colours($image_pixmap);
  }

  $X->ChangeWindowAttributes ($rootwin, background_pixmap => $pixmap);
  $X->ClearArea ($rootwin, 0,0,0,0);
  $X->FreePixmap ($pixmap);

  # _XSETROOT_ID the same as xsetroot and other rootwin programs do
  if ($root_visual_dynamic) {
    my $atom = $X->InternAtom('_XSETROOT_ID', 0);
    my ($value, $type, $format, $bytes_after)
      = $X->GetProperty($rootwin, $atom,
                        0,  # AnyPropertyType
                        0,  # offset
                        1,  # length
                        1); # delete;
    if ($type == XA_PIXMAP && $format == 32) {
      my $resource_pixmap = unpack 'L', $value;
      ### $value
      ### kill resource_pixmap: sprintf('%#X', $resource_pixmap)
      if ($resource_pixmap) { # watch out for None, maybe
        $X->KillClient($resource_pixmap);
      }
    }

    ### $want_save
    if ($want_save) {
      my $resource_pixmap = $X->new_rsrc;
      ### save resource_pixmap: sprintf('%#X', $resource_pixmap)
      $X->CreatePixmap ($resource_pixmap, $rootwin,
                        1,      # depth, bitmap
                        1, 1);  # width x height
      $X->ChangeProperty($rootwin, $atom, XA_PIXMAP,
                         32,  # format
                         'Replace',
                         pack ('L', $resource_pixmap));
      $X->SetCloseDownMode('RetainPermanent');
    }
  }
  $X->QueryPointer($rootwin);  # sync
  return 0;
}

sub _image_pixmap_any_allocated_colours {
  my ($image) = @_;
  my $colour_to_pixel = $image->get('-colour_to_pixel')
    || return 1;  # umm, dunno
  %$colour_to_pixel or return 0;  # no colours at all

  my $X        = $image->get('-X');
  my $screen   = $image->get('-screen');
  my $colormap = $image->get('-colormap') || return 0;  # no colormap

  my $screen_info = $X->{'screens'}->[$screen];
  $colormap == $screen_info->{'default_colormap'}
    || return 1;  # private colormap

  foreach my $pixel (values %$colour_to_pixel) {
    unless ($pixel == $screen_info->{'black_pixel'}
            || $pixel == $screen_info->{'white_pixel'}) {
      return 1;
    }
  }
  return 0; # only black and white and in the default colormap
}

my %visual_class_is_static = (StaticGray => 1,
                              StaticColor => 1,
                              TrueColor => 1);
# $visual is an XID
# return true if it has dynamic colour allocations
sub _X_visual_is_dynamic {
  my ($X, $visual) = @_;
  my $visual_info = $X->{'visuals'}->{$visual}
    || croak "Unknown visual $visual";
  return $visual_class_is_static{$visual_info->{'class'}};
}

# # return true if $pixel is one of the screen default colormaps
# sub _X_pixel_is_black_white {
#   my ($X, $pixel) = @_;
#   return ($pixel == $X->{'black_pixel'} || $pixel == $X->{'white_pixel'});
# }
# 
# # return true if $colormap is one of the screen default colormaps
# sub _X_colormap_is_default {
#   my ($X, $colormap) = @_;
#   return List::Util::first
#     {$colormap == $_->{'default_colormap'}} @{$X->{'screens'}};
# }

sub show_method_text_list {
  my ($self) = @_;
  my $gen = $self->make_generator;
  my $path = $gen->path_object;
  my $values_method = "values_make_$gen->{'values'}";
  my $iter = $gen->$values_method (1, 1000);

  my $count = 0;
  while (defined (my $n = $iter->())) {
    next if $n < 1;
    last if $count++ > 100;
    my ($x, $y) = $path->n_to_xy ($n)
      or next;
    printf "%4d  x=%g  y=%g\n", $n, $x, $y;
  }
  return 0;
}

sub show_method_text_numbers {
  my ($self) = @_;
  $self->term_size;
  my $gen = $self->make_generator;

  my $path = $gen->path_object;
  my $width = $gen->{'width'};
  my $height = $gen->{'height'};
  my $pwidth = int($width/5);
  my $pwidth_half = int($pwidth/2);
  my $height_half = int($height/2);

  my $rect_x1 = 0;
  my $rect_x2 = $pwidth-1;
  my $rect_y1 = 0;
  my $rect_y2 = $height-1;
  if ($path->x_negative) {
    $rect_x1 = -$pwidth_half;
    $rect_x2 = $pwidth_half;
  }
  if ($path->y_negative) {
    $rect_y1 = -$height_half;
    $rect_y2 = $height_half;
  }
  my ($n_lo, $n_hi) = $path->rect_to_n_range
    ($rect_x1, $rect_y1, $rect_x2, $rect_y2);

  my $values_method = "values_make_$gen->{'values'}";
  my $iter = $gen->$values_method ($n_lo, $n_hi);

  my %array;
  my $x_min = 0;
  my $y_min = 0;
  my $x_max = 0;
  my $y_max = 0;
  while (defined (my $n = $iter->())) {
    next if $n < $n_lo;
    last if $n > $n_hi;
    my ($x, $y) = $path->n_to_xy ($n)
      or next;
    ($array{$x}->{$y} .= "/$n") =~ s{^/}{};
    $x_min = min ($x_min, $x);
    $x_max = max ($x_max, $x);
    $y_min = min ($y_min, $y);
    $y_max = max ($y_max, $y);
  }
  if ($x_min < 0) {
    $x_min = -$pwidth_half;
    $x_max = $pwidth_half;
  } else {
    $x_max = min ($x_max, $pwidth);
  }
  if ($y_min < 0) {
    $y_min = -$height_half;
    $y_max = $height_half;
  } else {
    $y_max = min ($y_max, $height);
  }
  my $cell_width = 0;
  foreach my $y (reverse $y_min .. $y_max) {
    foreach my $x ($x_min .. $x_max) {
      my $elem = $array{$x}->{$y} || next;
      $cell_width = max ($cell_width, length($elem) + 1) ;
    }
  }
  foreach my $y (reverse $y_min .. $y_max) {
    foreach my $x ($x_min .. $x_max) {
      my $elem = $array{$x}->{$y};
      if (! defined $elem) { $elem = ''; }
      printf "%*s", $cell_width, $elem;
    }
    print "\n";
  }
  return 0;
}

sub show_method_prima {
  my ($self) = @_;
  require App::MathImage::Prima::Main;
  App::MathImage::Prima::Main->run;
  return 0;
}

# establish default width and height from Term::Size
sub term_size {
  my ($self) = @_;
  my $gen_options = $self->{'gen_options'};
  if (! defined $gen_options->{'width'}) {
    require Term::Size;
    my ($width, $height) = Term::Size::chars();
    ### term size
    ### $width
    ### $height

    $gen_options->{'width'} = (defined $width && $width >= 2
                               ? $width - 1 : 79);
    $gen_options->{'height'} = (defined $height && $height >= 2
                                ? $height -1 : 20);
  }
}

# return App::MathImage::Generator object
sub make_generator {
  my ($self) = @_;
  require App::MathImage::Generator;
  return App::MathImage::Generator->new (%{$self->{'gen_options'}});
}

1;
__END__

=for stopwords Ryde MathImage

=head1 NAME

App::MathImage -- math-image application module

=head1 SYNOPSIS

 use App::MathImage;
 my $mi = App::MathImage->new;
 exit $mi->command_line;

=head1 DESCRIPTION

This is the guts of the C<math-image> program, see L<math-image> for
user-level operation.

=head1 FUNCTIONS

=over 4

=item C<< $mi = App::MathImage->new (key=>value,...) >>

Create and return a new MathImage object.

=item C<< $exitcode = App::MathImage->command_line () >>

=item C<< $exitcode = $mi->command_line () >>

Run the C<math-image> program command line.  Arguments are taken from
C<@ARGV> and the return value is an exit code suitable for C<exit>.

=back

=head1 SEE ALSO

L<math-image>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-image/index.html

=head1 LICENSE

Copyright 2010 Kevin Ryde

Math-Image is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation; either version 3, or (at your option) any later
version.

Math-Image is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
Math-Image.  If not, see <http://www.gnu.org/licenses/>.

=cut
