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

use 5.004;
use strict;
use warnings;
use Test::More;

use lib 't';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings() }

eval { require Image::Magick }
  or plan skip_all => "due to no Image::Magick -- $@";
diag "Image::Magick VERSION ",Image::Magick->VERSION;

plan tests => 1536;
use_ok ('App::MathImage::Image::Base::Magick');

# uncomment this to run the ### lines
#use Smart::Comments;


#------------------------------------------------------------------------------
# VERSION

my $want_version = 43;
is ($App::MathImage::Image::Base::Magick::VERSION,
    $want_version, 'VERSION variable');
is (App::MathImage::Image::Base::Magick->VERSION,
    $want_version, 'VERSION class method');

ok (eval { App::MathImage::Image::Base::Magick->VERSION($want_version); 1 },
    "VERSION class check $want_version");
my $check_version = $want_version + 1000;
ok (! eval { App::MathImage::Image::Base::Magick->VERSION($check_version); 1 },
    "VERSION class check $check_version");

#------------------------------------------------------------------------------
# new

{
  my $image = App::MathImage::Image::Base::Magick->new
    (-width => 20,
     -height => 10);
  ok (! exists $image->{'-width'});
  ok (! exists $image->{'-height'});
  is ($image->get('-width'), 20);
  is ($image->get('-height'), 10);

  $image->set (-width => 15);
  is ($image->get('-width'), 15, 'resize -width');
  is ($image->get('-height'), 10, 'unchanged -height');
}


#------------------------------------------------------------------------------
# new() clone image, and resize

{
  my $i1 = App::MathImage::Image::Base::Magick->new
    (-width => 11, -height => 22);
  my $i2 = $i1->new;
  $i2->set(-width => 33, -height => 44);

  is ($i1->get('-width'), 11);
  is ($i1->get('-height'), 22);
  is ($i2->get('-width'), 33);
  is ($i2->get('-height'), 44);
  isnt ($i1->get('-imagemagick'), $i2->get('-imagemagick'));
}


#------------------------------------------------------------------------------
# xy()

{
  my $image = App::MathImage::Image::Base::Magick->new
    (-width => 20,
     -height => 10);
  $image->xy(3,4, '#AABBCC');
  is ($image->xy(3,4), '#AABBCC', 'xy() stored');
}
{
  my $image = App::MathImage::Image::Base::Magick->new
    (-width => 2, -height => 2);
  $image->set(-width => 20, -height => 20);

  diag explain $image;
  diag "xy() in resize store";
  $image->xy (10,10, '#FFFFFF');
  diag "xy() in resize read";
  is ($image->xy (10,10), '#FFFFFF', 'xy() in resize');
}


#------------------------------------------------------------------------------
# rectangle()

{
  my $image = App::MathImage::Image::Base::Magick->new
    (-width => 20,
     -height => 10);
  $image->get('-imagemagick')->Set (antialias => 0);

  $image->rectangle(2,2, 4,4, '#AABBCC');
  is ($image->xy(2,2), '#AABBCC', 'rectangle() unfilled drawn');
  is ($image->xy(3,3), '#000000', 'rectangle() unfilled centre undrawn');
}
{
  my $image = App::MathImage::Image::Base::Magick->new
    (-width => 20,
     -height => 10);
  $image->get('-imagemagick')->Set (antialias => 0);

  $image->rectangle(2,2, 4,4, '#AABBCC', 1);
  is ($image->xy(2,2), '#AABBCC', 'rectangle() filled drawn');
  is ($image->xy(3,3), '#AABBCC', 'rectangle() filled centre');

  # $image->get('-imagemagick')->Write ('xpm:-');  
}
{
  my $image = App::MathImage::Image::Base::Magick->new
    (-width => 20,
     -height => 10);
  $image->get('-imagemagick')->Set (antialias => 0);

  $image->rectangle(2,2, 2,2, '#AABBCC', 1);
  is ($image->xy(2,2), '#AABBCC', 'rectangle() 1x1 filled drawn');
}
{
  my $image = App::MathImage::Image::Base::Magick->new
    (-width => 20,
     -height => 10);
  $image->get('-imagemagick')->Set (antialias => 0);

  $image->rectangle(2,2, 2,2, '#AABBCC', 0);
  is ($image->xy(2,2), '#AABBCC', 'rectangle() 1x1 unfilled drawn');
}


#------------------------------------------------------------------------------
# line()

{
  my $image = App::MathImage::Image::Base::Magick->new
    (-width => 20,
     -height => 10);

  $image->get('-imagemagick')->Set (width => 10, height=> 5);
  $image->get('-imagemagick')->Set (antialias => 0);
  $image->line(0,0, 5,5, '#AABBCC');
  is ($image->xy(5,0), '#000000', 'line() away');
  is ($image->xy(2,2), '#AABBCC', 'line() drawn');
}


#------------------------------------------------------------------------------
# load() errors

my $filename = 'tempfile.png';
diag "Tempfile $filename";
unlink $filename;
ok (! -e $filename, "removed any existing $filename");
END {
  if (defined $filename) {
    diag "Remove tempfile $filename";
    unlink $filename
      or diag "No remove $filename: $!";
  }
}

{
  my $eval_ok = 0;
  my $ret = eval {
    my $image = App::MathImage::Image::Base::Magick->new
      (-file => $filename);
    $eval_ok = 1;
    $image
  };
  my $err = $@;
  # diag "new() err is \"",$err,"\"";
  is ($eval_ok, 0, 'new() error for no file - doesn\'t reach end');
  is ($ret, undef, 'new() error for no file - return undef');
  like ($err, '/^Exception/', 'new() error for no file - error string "Cannot"');
}
{
  my $eval_ok = 0;
  my $image = App::MathImage::Image::Base::Magick->new;
  my $ret = eval {
    $image->load ($filename);
    $eval_ok = 1;
    $image
  };
  my $err = $@;
  # diag "load() err is \"",$err,"\"";
  is ($eval_ok, 0, 'load() error for no file - doesn\'t reach end');
  is ($ret, undef, 'load() error for no file - return undef');
  like ($err, '/^Exception/', 'load() error for no file - error string "Cannot"');
}

#-----------------------------------------------------------------------------
# save() / load()

{
  my $image = App::MathImage::Image::Base::Magick->new (-width => 20,
                                                        -height => 10,
                                                        -file_format => 'png');
  $image->save ($filename);
  ok (-e $filename, "save() to $filename, -e exists");
  cmp_ok (-s $filename, '>', 0, "save() to $filename, -s non-empty");
}
{
  my $image = App::MathImage::Image::Base::Magick->new (-file => $filename);
  is ($image->get('-file_format'), 'PNG',
     'load() with new(-file)');
  ### $image
}
{
  my $image = App::MathImage::Image::Base::Magick->new;
  $image->load ($filename);
  is ($image->get('-file_format'), 'PNG',
      'load() method');
}

#------------------------------------------------------------------------------
# check_image()

{
  my $image = App::MathImage::Image::Base::Magick->new
    (-width  => 20,
     -height => 10);
  is ($image->get('-width'), 20);
  is ($image->get('-height'), 10);
  my $m = $image->get('-imagemagick');
  $m->Set (antialias => 0);

  require MyTestImageBase;
  MyTestImageBase::check_image ($image);
}

exit 0;
