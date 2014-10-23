#!/usr/bin/perl -w

# Copyright 2010 Kevin Ryde

# This file is part of Image-Base-Magick.
#
# Image-Base-Magick is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 3, or (at your option) any later
# version.
#
# Image-Base-Magick is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Image-Base-Magick.  If not, see <http://www.gnu.org/licenses/>.

use 5.010;
use strict;
use warnings;
use Image::Magick;

use Smart::Comments;

use lib 't';
use MyTestImageBase;

{
  my $m = Image::Magick->new;
  # $m->Set(width=>10, height => 10);
  $m->Set(size=>'20x10');
  $m->ReadImage('xc:black');

  say $m->Get('width');
  say $m->Get('height');
  say $m->Get('size');

  $m->Draw(fill=>'black',
           primitive=>'rectangle',
           points=>'5,5 5,6');

  #   $m->Draw(stroke=>'red', primitive=>'rectangle',
  #            points=>'5,5, 5,5');

  #   $m->Draw(fill => 'black',
  #            primitive=>'point',
  #            point=>'5,5');

  # $m->Set('pixel[5,5]'=>'red');
  say $m->GetPixel (x => 5, y => 5);
  say $m->Get ('Pixel[5,5]');

  #   $m->Write ('xpm:-');
  exit 0;

  $m->Set (size=>'20x10');
  $m->Set (magick=>'xpm');
  $m = Image::Magick->new;
  $m->Set(size=>'20x10');
  $m->ReadImage('xc:white');

  # #$m->Read ('/usr/share/emacs/22.3/etc/images/icons/emacs_16.png');
  #   $m->Draw (primitive => 'rectangle',
  #             points => '0,0, 19,9',
  #             method => 'Replace',
  #             stroke => 'black',
  #             fill => 'black',
  #            );

  $m->Draw (primitive => 'point',
            points => '0,0, 2,2',
            method => 'Replace');

  $m->Quantize(colours => 4);
  exit 0;
}

{
  $ENV{'DISPLAY'} = ':0';
  my $X = X11::Protocol->new;
  my $win = $X->new_rsrc;

  my $image = Image::Base::X11::Protocol::Pixmap->new
    (-X      => $X,
     -width  => 50,
     -height => 50,
     -depth  => 1,
    # -for_drawable => $X->{'root'},
    );
  ### -colormap: $image->get('-colormap')
  $image->rectangle (0,0, 99,99, 'clear', 1);

  $image->rectangle (10,10,50,50, 'set');
  say $image->xy (10,10);
  exit 0;
}

{
  $ENV{'DISPLAY'} = ':0';
  my $X = X11::Protocol->new;
   ### $X
  my $win = $X->new_rsrc;
  $X->CreateWindow($win, $X->root,
                   'InputOutput',
                   $X->root_depth,
                   'CopyFromParent',
                   -20,-20,
                   100,100,
                   5,   # border
                   background_pixel => 0x123456, # $X->{'white_pixel'},
                   override_redirect => 1,
                   colormap => 'CopyFromParent',
                   save_under => 1,
                  );
  $X->MapWindow ($win);
  $X->ClearArea ($win,0,0,0,0);
  $X->ConfigureWindow ($win, stack_mode => 'Below');
  # ### attrs: $X->GetWindowAttributes ($win)

#   my $bytes = $X->GetImage($win,0,0,1,1,~0,'ZPixmap');
#   ### $bytes

  my @ret = $X->robust_req('GetImage',$win,30,30,1,1,~0,'ZPixmap');
  ### @ret

  $X->handle_input;
  exit 0;
}

{
  $ENV{'DISPLAY'} = ':0';
  my $X = X11::Protocol->new;
  $X->init_extension('SHAPE');
  { local $,=' ', say keys %{$X->{'ext'}}; }

  my $win = $X->new_rsrc;
  $X->CreateWindow($win, $X->root,
                   'InputOutput',
                   $X->root_depth,
                   'CopyFromParent',
                   0,0,
                   100,100,
                   10,   # border
                   background_pixel => $X->{'white_pixel'},
                   override_redirect => 1,
                   colormap => 'CopyFromParent',
                  );
  $X->MapWindow ($win);
  ### attrs: $X->GetWindowAttributes ($win)
  # $X->ClearArea ($win, 0,0,0,0);

  my $image = Image::Base::X11::Protocol::Window->new
    (-X => $X,
     -window => $win);
  $image->rectangle (0,0, 99,99, 'light grey', 1);

  $image->ellipse (10,10,50,50, 'black');
  $image->rectangle (10,10,50,50, 'black');

  # $image->rectangle (0,0, 50,50, 'None', 1);
  #   foreach my $i (0 .. 10) {
  #      $image->ellipse (0+$i,0+$i, 50-1*$i,50-1*$i, 'None', 1);
  #     # $image->line (0+$i,0, 50-$i,50, 'None', 1);
  #   }

  $X->handle_input;
  sleep 10;
  exit 0;
}

{
  $ENV{'DISPLAY'} = ':0';
  my $X = X11::Protocol->new;
  #  ### $X
  $X->choose_screen(0);
  ### image_byte_order: $X->{'image_byte_order'}

  ### 0: $X->interp('Significance', 0)
  ### 1: $X->interp('Significance', 1)
  ### 2: $X->interp('Significance', 2)

  print "image_byte_order $X->{'image_byte_order'}\n";
  print "black $X->{'black_pixel'}\n";
  print "white $X->{'white_pixel'}\n";
  print "default_colormap $X->{'default_colormap'}\n";

  my $rootwin = $X->{'root'};
  print "rootwin $rootwin\n";
  my $depth = $X->{'root_depth'};
  print "depth $depth\n";
  my $colormap = $X->{'default_colormap'};

  #   my $image = Image::Base::X11::Protocol::Pixmap->new
  #     (-X => $X,
  #      -palette  => { black => $X->{'black_pixel'},
  #                     white => $X->{'white_pixel'},
  #                   },
  #      -width    => 10,
  #      -height   => 10,
  #      -depth    => $depth,
  #      -colormap => $colormap,
  #      -for_window => $rootwin);
  # #   require Data::Dumper;
  # #   print Data::Dumper->new([$image],['image'])->Dump;

  my $image = Image::Base::X11::Protocol::Drawable->new
    (-X => $X,
     -palette  => { black => $X->{'black_pixel'},
                    white => $X->{'white_pixel'},
                  },
     -depth    => $depth,
     -drawable => $rootwin);
  # -colormap => $X->{'default_colormap'});
  ### get(-colormap): $image->get('-colormap')

  print "width ",$image->get('-width'),"\n";
  print "height ",$image->get('-height'),"\n";
  print "colormap ",$image->get('-colormap'),"\n";

#   $image->rectangle (0,0, 9,9, 'light green', 1);
#   $image->line (1,1, 5,5, '#AA00AA');

  print "get xy ",$image->xy(0,0),"\n";
  exit 0;

  #   my $pixmap = $image->get('-drawable');
  #   print "-drawable $pixmap\n";
  #   $X->ChangeWindowAttributes ($rootwin, background_pixmap => $pixmap);
  #
  #   $X->ClearArea ($rootwin, 0,0,0,0);
  #
  #   undef $image;
  #   $X->handle_input;
  #
  #   exit 0;
}
{
  $ENV{'DISPLAY'} = ':0';
  my $X = X11::Protocol->new;
  my $colormap = $X->{'default_colormap'};
  my $rootwin = $X->{'root'};
  ### geom: $X->GetGeometry($rootwin)
  exit 0;
}



{
  $ENV{'DISPLAY'} = ':0';
  my $X = X11::Protocol->new;

  my $rootwin = $X->{'root'};
  print "rootwin $rootwin\n";
  my $depth = $X->{'root_depth'};
  print "depth $depth\n";
  my $colormap = $X->{'default_colormap'};

  my $image = Image::Base::X11::Protocol::Drawable->new
    (-X        => $X,
     -drawable => $rootwin);

  my @points = (0,0) x 500000;
  $image->Image_Base_Other_xy_points ('black', @points);

  $X->QueryPointer($rootwin);  # sync
  $X->handle_input;

  exit 0;
}


#   if (! exists $self->{'-colormap'}) {
#     my $X = $self->{'-X'};
#     my $screen_info;
#     if (defined (my $screen_num = $self->{'-for_screen'})) {
#       $screen_info = $X->{'screens'}->[$screen_num];
#     } else {
#       $screen_info
#         = _X_rootwin_to_screen_hash($X, $self->{'-drawable'})
#           || _X_rootwin_to_screen_hash($X,$self->get('-root'))
#             || croak "Oops, cannot find rootwin among screens";
#     }
#     $self->{'-colormap'} = $screen_info->{'default_colormap'};
#   }
#   return $self;
#     ### $pixel
#     if (my $gc = $self->{'-gc'}) {
#     } else {
#       my $gc = $self->{'-gc'} = $self->{'_gc_created'} = $X->new_rsrc;
#       ### CreateGC: $gc
#       $X->CreateGC ($gc, $self->{'-drawable'}, foreground => $pixel);
#     }

#   foreach my $key ('-width', '-height', '-depth') {
#     if (exists $params{$key}) {
#       croak "Attribute $key is read-only";
#     }
#   }

# =item C<-colormap> (XID integer)
# 
# The colormap to allocate colours in when drawing.  If not supplied then when
# required it's set from the colormap installed on the window
# (C<GetWindowAttributes>).  If you already know the colormap then supplying
# it in C<new> or a C<set> saves a server round-trip.




