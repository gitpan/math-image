#!/usr/bin/perl -w

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

use 5.010;
use strict;
use warnings;
use Image::Magick;

use Smart::Comments;

use lib 't';
use MyTestImageBase;



{
  use strict;
  use warnings;
  use Image::Magick;

  unlink "/tmp/out.png";
  my $m = Image::Magick->new (size => '1x1');
  if (!$m) { die; }
  ### $m

  my $err = $m->ReadImage('xc:black');
  if ($err) { die $err; }
  ### $m

  $m->Write (filename => "/tmp/x%d.png",
             # quality => 75,
            );

  $m = Image::Magick->new; #  (size => '64x64');
  if (!$m) { die; }
  ### $m

  # $err = $m->SetAttribute (debug => 'all,trace');
  # $err = $m->SetAttribute (debug => 'all');
  # if ($err) { die $err; }

  # $m->set(filename => "/tmp/x%d.png");
  # $m->ReadImage('xc:black');
  #  $err = $m->Read ();

  open FH, '</tmp/x%d.png' or die;
  $err = $m->Read (file => \*FH,
                   # filename => "/tmp/x%d.png",
                  );
  ### $err
  ### $m
  ### magick: $m->Get('magick')

  $m->Write ("/tmp/out.png");
  exit 0;
}

{
  require App::MathImage::Image::Base::Magick;
  my $image = App::MathImage::Image::Base::Magick->new
    (-width  => 20,
     -height => 10,
    );
  my $m = $image->{'-imagemagick'};
  $m->Set (size => '20x10') and die;
  $m->Set (width => '20') and die;
  $m->Set (height => '10') and die;
  $m->Set (strokewidth => 0) and die;
  ### setsize width: $m->Get('width')
  ### setsize size: $m->Get('size')

  $image->rectangle (0,0, 19,9, 'black', 1);


  $m->Draw(stroke=>'white',
           primitive=>'ellipse',
           points=>'5,5, 4,4, 0,360');

  # $image->line (1,1, 1,1, 'white');
  # $image->rectangle (1,1, 1,1, 'white', 1);
  # $image->ellipse (1,1, 18,8, 'white', 1);
  # $image->ellipse (1,1, 2,2, 'white', 0);

  $m->Write ('xpm:-');
  exit 0;
}

{
  my $m = Image::Magick->new (
                              # width => 20, height => 10,
                              # size => '20x10',
                              # size => '20x',
                             );
  ### initial width: $m->Get('width')
  ### initial size: $m->Get('size')
  ### format: $m->Get('format')
  ### magick: $m->Get('magick')

  $m->Read('/usr/share/emacs/23.2/etc/images/icons/hicolor/16x16/apps/emacs.png');
  # $m->Set(size=>'20x10');
  # $m->Set (width => 18);
  ### png width: $m->Get('width')
  ### png size: $m->Get('size')

  $m->Set (size => '6x8');
  ### setsize width: $m->Get('width')
  ### setsize size: $m->Get('size')

  ### format: $m->Get('format')
  ### magick: $m->Get('magick')
  ### filename: $m->Get('filename')

  $m->Set(filename => '/tmp/zz.png');
  $m->Write;
  exit 0;
}

{
  my $m = Image::Magick->new;
  ### m: $m->Get('magick')
  $m->Read('/usr/share/emacs/23.2/etc/images/icons/hicolor/16x16/apps/emacs.png');
  ### magick: $m->Get('magick')
  ### width: $m->Get('width')
  ### height: $m->Get('width')
  ### size: $m->Get('size')
  # $m->Set(magick => '');
  ### m: $m->Get('magick')
  $m->Read('/usr/share/webcheck/favicon.ico');
  ### m: $m->Get('magick')

  $m->Write(filename => '/tmp/image%%03d.data');
  exit 0;
}

{
  my $m = Image::Magick->new;
  # $m->Set(width=>10, height => 10);
  $m->Set(size=>'20x10');
  $m->ReadImage('xc:black');

  say $m->Get('width');
  say $m->Get('height');
  say $m->Get('size');

  # $m->Draw(fill=>'white',
  #          primitive=>'rectangle',
  #          points=>'5,5 5,5');
  $m->Draw(fill=>'white',
           primitive=>'point',
           points=>'5,5');

  #   $m->Draw(stroke=>'red', primitive=>'rectangle',
  #            points=>'5,5, 5,5');

  #   $m->Draw(fill => 'black',
  #            primitive=>'point',
  #            point=>'5,5');

  # $m->Set('pixel[5,5]'=>'red');
  say $m->GetPixel (x => 5, y => 5);
  say $m->Get ('Pixel[5,5]');

  $m->Write ('xpm:-');
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
  use strict;
  use warnings;
  use Image::Magick;

  my $m = Image::Magick->new (size => '20x10');
  if (!$m) { die; }
  ### $m

  my $err = $m->ReadImage('xc:black');
  if ($err) { die $err; }
  ### $m

  $err = $m->SetPixel (x=>3, y=>4, color=>'#AABBCC');
  if ($err) { die $err; }

  exit 0;
}
