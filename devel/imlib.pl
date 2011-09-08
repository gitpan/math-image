#!/usr/bin/perl -w

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

use 5.004;
use strict;

# uncomment this to run the ### lines
use Smart::Comments;

{
  for (;;) {
    require App::MathImage::Image::Base::Imlib2;
    my $image = App::MathImage::Image::Base::Imlib2->new;
    $image->set(-quality => 55);
  }
}


{
  # diamond
  #
  require App::MathImage::Image::Base::Imlib2;
  my $image = App::MathImage::Image::Base::Imlib2->new
    (-width => 50, -height => 25,
     -file_format => 'png');

  # $image->diamond (3,2, 13,2, '#0F0', 0);
  # $image->diamond (3,5, 13,5, '#0F0', 1);

#  $image->ellipse (5,6, 7,8, '#0F0', 1);
  $image->ellipse (15,16, 25,20, '#0F0', 1);

  $image->save ('/tmp/x.png');
  system ('convert /tmp/x.png /tmp/x.xpm && cat /tmp/x.xpm');
  exit 0;
}

{
  require App::MathImage::Image::Base::Imlib2;
  my $image = App::MathImage::Image::Base::Imlib2->new
    (-width => 50, -height => 20,
     -file_format => 'png');
  $image->rectangle (0,0, 49,29, '#000', 1);
  # $image->get('-imlib')->set_anti_alias(0);

  $image->ellipse (1,1,6,6, '#FFF');
  $image->ellipse (11,1,16,6, '#FFF', 1);
  $image->ellipse (1,10,7,16, '#FFF');
  $image->ellipse (11,10,17,16, '#FFF', 1);

  $image->save ('/tmp/x.png');
  system ('convert /tmp/x.png /tmp/x.xpm && cat /tmp/x.xpm');
  exit 0;
}
{
  my $imager = Imlib2->new (file =>
                            '/tmp/x001.tiff',
                            # '/usr/share/pyshared/pygame/pygame_icon.tiff'
                            # '/usr/share/emacs/23.2/etc/images/icons/hicolor/16x16/apps/emacs.png',
                            # '/usr/share/doc/dhttpd/dhttpd102.gif',
                            # '/usr/share/doc/eekboek/html/images/bg.gif',
                            # '/usr/share/doc/libgd-graph-perl/examples/samples/sample62.gif',
                           );

  # $imager->setpixel (x => 1, y => 1, color => 'pink');


  # my @colors = ('#112233',
  #               Imlib2::Color->new('pink'),
  #              );
  # my @addcolors = $imager->addcolors (colors => \@colors);
  # ### @addcolors

  $imager->addtag (name => 'zz', value => 'blah');
  $imager->addtag (name => 'zz', value => 'fjks');
  $imager->addtag (name => 'i_format', value => 'blah');

  print "Image information:\n";
  print "Width:        ", $imager->getwidth(),    "\n";
  print "Height:       ", $imager->getheight(),   "\n";
  print "Channels:     ", $imager->getchannels(), "\n";
  print "Bits/Channel: ", $imager->bits(),        "\n";
  print "Virtual:      ", $imager->virtual() ? "Yes" : "No", "\n";
  my $colorcount = $imager->getcolorcount(maxcolors=>512);
  print "Actual number of colors in image: ";
  print defined($colorcount) ? $colorcount : ">512", "\n";
  print "Palette colorcount: ",or_undef($imager->colorcount),"\n";
  print "Palette maxcolors:  ",or_undef($imager->maxcolors),"\n";
  print "Type:         ", $imager->type(),        "\n";

  print "Tags:\n";
  my @tags = $imager->tags;
  foreach my $tag (@tags) {
    my $key = shift @$tag;
    print " $key: ", join(" - ", @$tag), "\n";
  }

  my @ret = $imager->tags (name => 'i_format');
  ### @ret

  my $filename = '/tmp/zz.png';
  $imager->write (file => $filename,
                  type => 'jpeg',
                  # (defined $file_format ? (type => $file_format) : ()),
                 )
    or die "Cannot save $filename: ",$imager->errstr;
  system ('ls -l /tmp/zz*');
  system ('file /tmp/zz*');

  exit 0;

  sub or_undef {
    my ($thing) = @_;
    return (defined $thing ? $thing : '[undef]');
  }
}

{
  # tiff write
  my $i = Imlib2->new (xsize => 200, ysize => 100);
  $i->write(file => '/tmp/x100.tiff',
            tiff_compression => 'jpeg',
            tiff_jpegquality => 100,
           )
    or die $i->errstr;
  $i->write(file => '/tmp/x001.tiff',
            tiff_compression => 'jpeg',
            tiff_jpegquality => 50)
    or die $i->errstr;
  system "ls -l /tmp/x*.tiff";
  exit 0;
}
{
  # jpeg compression on save()
  #
  require Image::Base::Imlib2;
  my $image = Image::Base::Imlib2->new
    (-width => 200, -height => 100,
     -file_format => 'jpeg');
  $image->ellipse (1,1, 100,50, 'green');
  $image->ellipse (100,50, 199,99, 'orange');
  $image->line (1,99, 199,0, 'red');
  $image->set (-quality_percent => 1);
  $image->save ('/tmp/x-001.jpeg');
  $image->set (-quality_percent => 100);
  $image->save ('/tmp/x-100.jpeg');
  system "ls -l /tmp/x*";
  exit 0;
}

{
  require Image::Base::Imlib2;
  my $image = Image::Base::Imlib2->new
    (-width => 20, -height => 10,
     -hotx => 7, -hoty => 8,
     -file_format => 'cur');
  $image->save ('/tmp/zz.ccc');
  $image->set (-file_format => 'ico');
  $image->save ('/tmp/zz.iii');
  $image->set (-file_format => 'cur');

  $image->set (-hotx => 3, -hoty => 4);

  # $image = Image::Base::Imlib2->new
  #   (-width => 20, -height => 10,
  #    -hotx => 3, -hoty => 4,
  #    -file_format => 'ICO');
  $image->save ('/tmp/zz2.xyz');

  $image = Image::Base::Imlib2->new
    (-file => '/tmp/zz2.xyz');
  ### -file_format: $image->get('-file_format')

  # ### read_types: sort Imlib2->read_types
  # ### write_types: sort Imlib2->write_types
  # my $iformats = \%Imlib2::formats;
  # ### $iformats

  exit 0;
}


{
  my $i = Imlib2->new (xsize => undef, ysize => undef);
  ### $i
  ### errstr: Imlib2->errstr
  ### width: $i->getwidth
  ### height: $i->getheight
  $i->settag (name => 'i_format', value => 'CUR');
  $i->settag (name => 'cur_hotspotx', value => 5);
  ### tags: [$i->tags]
  exit 0;
}
{
  print join(',', sort Imlib2->write_types), "\n";
  my $i = Imlib2->new(xsize=>1,ysize=>1);
  my @ret = $i->write (file => '/tmp/x.png',
                       # type => 'fjdkslfsjkl',
                      );
  ### @ret
  print join(',', sort Imlib2->write_types), "\n";
  exit 0;
}




{
  ### read_types: sort Imlib2->read_types
  ### write_types: sort Imlib2->write_types
  exit 0;
}





{
  foreach my $c (scalar (Imlib2::Color->new(xname => 'pink')),
                 scalar (Imlib2::Color->new(gimp => 'pink')),
                 scalar (Imlib2::Color->new(builtin => 'pink')),
                 scalar (Imlib2::Color->new(name => 'green')),
                ) {
    ### $c
    ### rgba: $c && $c->rgba
  }
  exit 0;
}


